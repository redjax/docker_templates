package utils

import "os/exec"

// IsCommandAvailable checks if a command is available in the PATH.
func IsCommandAvailable(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}
