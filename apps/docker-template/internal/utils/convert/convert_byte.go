package convert

import (
	"fmt"
	"strconv"
	"strings"
)

func BytesToHumanReadable(bytes uint64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}

	div, exp := uint64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}

	// Units: KB, MB, GB, TB, PB, EB, ZB, YB
	units := []string{"KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"}

	if exp >= len(units) {
		return fmt.Sprintf("%.1f B", float64(bytes))
	}

	return fmt.Sprintf("%.1f %s", float64(bytes)/float64(div), units[exp])
}

// ParseByteSize parses strings like "10MB", "1GB", "512K", or "15615" (bytes) into an int64 byte count.
// Supports both SI (kB, MB, GB) and IEC (KiB, MiB, GiB) units, case-insensitive.
func ParseByteSize(s string) int64 {
	s = strings.TrimSpace(strings.ToUpper(s))
	multipliers := map[string]int64{
		"B":   1,
		"K":   1 << 10, // 1024
		"KB":  1 << 10,
		"KIB": 1 << 10,
		"M":   1 << 20, // 1024*1024
		"MB":  1 << 20,
		"MIB": 1 << 20,
		"G":   1 << 30,
		"GB":  1 << 30,
		"GIB": 1 << 30,
		"T":   1 << 40,
		"TB":  1 << 40,
		"TIB": 1 << 40,
	}

	// Find where the number ends and the unit begins
	i := 0
	for ; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			if s[i] != '.' { // allow decimal point
				break
			}
		}
	}
	numPart := s[:i]
	unitPart := strings.TrimSpace(s[i:])

	// Default to bytes if no unit
	if unitPart == "" {
		unitPart = "B"
	}

	val, err := strconv.ParseFloat(numPart, 64)
	if err != nil {
		return 0 // or handle error as needed
	}
	mult, ok := multipliers[unitPart]
	if !ok {
		return 0 // or handle error as needed
	}
	return int64(val * float64(mult))
}
