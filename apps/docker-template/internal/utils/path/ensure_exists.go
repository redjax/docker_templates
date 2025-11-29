package path

import (
	"fmt"
	"os"
)

// EnsureDirExists ensures that a directory path exists, creating it (including parent directories) if necessary.
// If no permission is provided, it defaults to 0755 (rwxr-xr-x).
//
// Parameters:
//   - path: The directory path to ensure exists
//   - perm: Optional file permissions (pass 0 or negative to use default 0755)
//
// Returns:
//   - error: nil if successful, error otherwise
//
// Example:
//
//	// Use default permissions (0755)
//	err := EnsureDirExists("/path/to/dir", 0)
//
//	// Use custom permissions (0700)
//	err := EnsureDirExists("/path/to/dir", 0700)
func EnsureDirExists(path string, perm os.FileMode) error {
	// Use default permission 0755 if no valid permission is provided
	if perm == 0 {
		perm = 0755
	}

	// Check if path already exists
	info, err := os.Stat(path)
	if err == nil {
		// Path exists, verify it's a directory
		if !info.IsDir() {
			return fmt.Errorf("path exists but is not a directory: %s", path)
		}
		return nil
	}

	// If error is not "does not exist", return the error
	if !os.IsNotExist(err) {
		return fmt.Errorf("error checking path: %w", err)
	}

	// Create directory with all parent directories
	if err := os.MkdirAll(path, perm); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	return nil
}
