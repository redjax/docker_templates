package version

import (
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strings"
)

var (
	Version = "dev"
	Commit  = "none"
	Date    = "unknown"

	// Change this for new packages
	RepoUrl = "https://github.com/redjax/docker_templates.git"
)

type PackageInfo struct {
	PackageName        string
	RepoUrl            string
	RepoUser           string
	RepoName           string
	PackageVersion     string
	PackageCommit      string
	PackageReleaseDate string
}

// GetPackageInfo returns a struct with information about the current package
func GetPackageInfo() PackageInfo {
	exePath, err := os.Executable()
	binName := "<unknown>"

	if err == nil {
		binName = filepath.Base(exePath)
	}

	return PackageInfo{
		PackageName:        binName,
		RepoUrl:            RepoUrl,
		PackageVersion:     Version,
		PackageCommit:      Commit,
		PackageReleaseDate: Date,
	}
}

// Returns the user/repo portion of a repository URL
func getRepoUrlPath() (string, error) {
	u, err := url.Parse(RepoUrl)
	if err != nil {
		return "", fmt.Errorf("invalid URL: %w", err)
	}

	// Trim leading and trailing slashes for safe splitting
	trimmedPath := strings.Trim(u.Path, "/")

	// Split the path
	segments := strings.Split(trimmedPath, "/")
	if len(segments) < 2 {
		return "", fmt.Errorf("URL doesn't contain enough path segments for user/repo")
	}

	return fmt.Sprintf("%s/%s", segments[0], segments[1]), nil
}

func compareVersion(version1 string, version2 string) int {
	// Strip suffixes (like -abcdef123)
	ver1 := strings.SplitN(version1, "-", 2)[0]
	ver2 := strings.SplitN(version2, "-", 2)[0]

	s1 := strings.Split(ver1, ".")
	s2 := strings.Split(ver2, ".")

	maxlen := len(s1)
	if len(s2) > maxlen {
		maxlen = len(s2)
	}

	for i := 0; i < maxlen; i++ {
		var n1, n2 int
		if i < len(s1) {
			fmt.Sscanf(s1[i], "%d", &n1)
		}
		if i < len(s2) {
			fmt.Sscanf(s2[i], "%d", &n2)
		}
		if n1 > n2 {
			return 1
		}
		if n1 < n2 {
			return -1
		}
	}
	return 0
}

// PrintVersion prints version information
func PrintVersion() {
	pkgInfo := GetPackageInfo()

	fmt.Printf("package: %s version:%s commit:%s date:%s\n", pkgInfo.PackageName, pkgInfo.PackageVersion, pkgInfo.PackageCommit, pkgInfo.PackageReleaseDate)
}
