// The main entrypoint for the app.
// When you run with `go run ...`, you can point to this file to launch the CLI app.
// You can build separate binaries by targeting other endpoints with `go build`.
// Creating additional entrypoints is as simple as making a file in cmd/entrypoints/*.go and calling it with `go run` and `go build`.
package main

import (
	// Import the cmd directory with root.go
	"local/docker-templates/cmd"

	// Import version package for doing self upgrade
	"local/docker-templates/internal/version"
)

func main() {
	// Check if an update is needed
	version.TrySelfUpgrade()

	// Call the root command
	cmd.Execute()
}
