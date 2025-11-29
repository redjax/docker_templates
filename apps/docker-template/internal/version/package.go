package version

import (
	"fmt"

	"github.com/spf13/cobra"
)

func showPackageInfo(cmd *cobra.Command, args []string) error {
	pkgInfo := GetPackageInfo()

	fmt.Printf(
		"Program: %s\nOwner: %s\nRepository Name: %s\nRepository URL: %s\nVersion: %s\nCommit: %s\nRelease Date: %s",
		pkgInfo.PackageName,
		pkgInfo.RepoUser,
		pkgInfo.RepoName,
		pkgInfo.RepoUrl,
		Version,
		Commit,
		Date,
	)

	return nil
}
