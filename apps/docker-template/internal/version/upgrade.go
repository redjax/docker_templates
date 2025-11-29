package version

import (
	"archive/zip"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strings"

	"github.com/spf13/cobra"
)

// UpgradeSelf is the entrypoint for 'docker-templates self upgrade'.
func UpgradeSelf(cmd *cobra.Command, args []string, checkOnly bool) error {
	info := GetPackageInfo()

	repo, err := getRepoUrlPath()
	if err != nil {
		fmt.Fprintf(cmd.ErrOrStderr(), "Error getting repository path (user/repo): %v\n", err)
		return err
	}

	apiURL := fmt.Sprintf("https://api.github.com/repos/%s/releases/latest", repo)
	fmt.Fprintln(cmd.ErrOrStderr(), "Checking for latest release...")

	resp, err := http.Get(apiURL)
	if err != nil {
		return fmt.Errorf("failed to fetch latest release: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("GitHub API returned status: %s", resp.Status)
	}

	var release struct {
		TagName string `json:"tag_name"`
		Assets  []struct {
			Name               string `json:"name"`
			BrowserDownloadURL string `json:"browser_download_url"`
		} `json:"assets"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		return fmt.Errorf("failed to parse release JSON: %w", err)
	}

	current := info.PackageVersion
	latest := release.TagName

	fmt.Fprintln(cmd.ErrOrStderr(), "Current version:", current)
	fmt.Fprintln(cmd.ErrOrStderr(), "Latest version: ", latest)

	// Dev Build Detection
	if strings.HasPrefix(current, "0.0.0-") {
		fmt.Fprintf(cmd.ErrOrStderr(), "⚠️  This is a development release: %s\n", current)
		// Continue if you still want to allow upgrade, or return early
	}

	// Version Comparison
	cmp := compareVersion(current, latest)
	if checkOnly {
		switch cmp {
		case -1:
			fmt.Fprintf(cmd.ErrOrStderr(), "🚀 Upgrade available: %s → %s\n", current, latest)
			fmt.Fprintln(cmd.ErrOrStderr(), "✅ Use this command without --check to upgrade.")
		case 0:
			fmt.Fprintf(cmd.ErrOrStderr(), "🔄 No new release available – you are up to date (%s).\n", current)
		case 1:
			fmt.Fprintf(cmd.ErrOrStderr(), "🕑 You're ahead of the latest release: current=%s, release=%s\n", current, latest)
		}
		return nil
	}

	// Prepare platform asset name: e.g. linux-amd64.zip
	normalizedOS := normalizeOS(runtime.GOOS)
	expectedPrefix := fmt.Sprintf("%s-%s", normalizedOS, runtime.GOARCH)

	var assetURL string
	for _, asset := range release.Assets {
		if strings.HasPrefix(asset.Name, expectedPrefix) && strings.HasSuffix(asset.Name, ".zip") {
			assetURL = asset.BrowserDownloadURL
			break
		}
	}

	if assetURL == "" {
		return fmt.Errorf("no suitable release found for platform: %s/%s", runtime.GOOS, runtime.GOARCH)
	}

	fmt.Fprintln(cmd.ErrOrStderr(), "Downloading:", assetURL)

	resp2, err := http.Get(assetURL)
	if err != nil {
		return fmt.Errorf("failed to download binary zip: %w", err)
	}
	defer resp2.Body.Close()

	zipTmp, err := os.CreateTemp("", "docker-templates-upgrade-*.zip")
	if err != nil {
		return fmt.Errorf("failed to create temp zip file: %w", err)
	}
	defer os.Remove(zipTmp.Name())

	if _, err := io.Copy(zipTmp, resp2.Body); err != nil {
		return fmt.Errorf("failed to write zip file: %w", err)
	}
	zipTmp.Close()

	// Extract binary from zip
	binaryTmp, err := extractBinaryFromZip(zipTmp.Name())
	if err != nil {
		return fmt.Errorf("failed to extract binary: %w", err)
	}
	defer os.Remove(binaryTmp)

	// Prepare self-replacement
	exePath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("failed to get executable path: %w", err)
	}

	newPath := exePath + ".new"
	if err := copyFile(binaryTmp, newPath); err != nil {
		return fmt.Errorf("failed to copy new binary: %w", err)
	}

	fmt.Fprintf(cmd.ErrOrStderr(),
		"✅ Upgrade downloaded:\n  %s\n"+
			"  It will be applied the next time you run the command.\n",
		newPath)

	return nil
}

// normalizeOS maps runtime.GOOS to your release asset naming
func normalizeOS(goos string) string {
	if goos == "darwin" {
		return "macOS"
	}

	return goos
}

// extractBinaryFromZip extracts the binary from a zip file and returns path
func extractBinaryFromZip(zipPath string) (string, error) {
	r, err := zip.OpenReader(zipPath)
	if err != nil {
		return "", err
	}
	defer r.Close()

	for _, f := range r.File {
		if f.FileInfo().IsDir() {
			continue
		}

		rc, err := f.Open()
		if err != nil {
			return "", err
		}
		defer rc.Close()

		tmpBin, err := os.CreateTemp("", "docker-templates-bin-*")
		if err != nil {
			return "", err
		}

		if _, err := io.Copy(tmpBin, rc); err != nil {
			tmpBin.Close()
			return "", err
		}

		tmpBin.Close()

		if err := os.Chmod(tmpBin.Name(), 0755); err != nil {
			return "", err
		}

		return tmpBin.Name(), nil
	}

	return "", fmt.Errorf("no binary found in zip archive")
}

// copyFile utility
func copyFile(src, dst string) error {
	in, err := os.Open(src)

	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}

	defer out.Close()

	if _, err := io.Copy(out, in); err != nil {
		return err
	}

	return out.Chmod(0755)
}

// TrySelfUpgrade checks if "<binary>.new" exists and replaces current binary with it.
func TrySelfUpgrade() {
	exePath, err := os.Executable()
	if err != nil {
		return
	}

	newPath := exePath + ".new"

	if _, err := os.Stat(newPath); err == nil {
		// New file exists: perform replacement
		if err := os.Rename(newPath, exePath); err == nil {
			fmt.Fprintf(os.Stderr, "🔁 docker-templates upgraded successfully.\n")
		}
	}
}
