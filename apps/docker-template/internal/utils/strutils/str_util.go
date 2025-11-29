package strutils

import (
	"regexp"
	"strings"
	"unicode"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

// ToUpper returns s converted to uppercase.
func ToUpper(s string) string {
	return strings.ToUpper(s)
}

// ToLower returns s converted to lowercase.
func ToLower(s string) string {
	return strings.ToLower(s)
}

// ToTitleCase returns the string with the first letter of each word capitalized.
// e.g. "hello world" → "Hello World"
func ToTitleCase(s string) string {
	// Create a Unicode-aware title caser
	caser := cases.Title(language.English)

	// Apply title casing to lowercase string
	return caser.String(strings.ToLower(s))
}

// Capitalize returns the string with only the first character uppercased.
// e.g. "hello world" → "Hello world"
func Capitalize(s string) string {
	if s == "" {
		return s
	}

	runes := []rune(s)
	runes[0] = unicode.ToUpper(runes[0])

	return string(runes)
}

// Updated function signature
func RemoveSubstrings(s string, removeList []string, ignoreCase bool) string {
	for _, r := range removeList {
		if ignoreCase {
			// Build case-insensitive regex pattern
			re := regexp.MustCompile(`(?i)` + regexp.QuoteMeta(r))
			s = re.ReplaceAllString(s, "")
		} else {
			s = strings.ReplaceAll(s, r, "")
		}
	}

	return s
}

// ReplaceSubstrings applies search/replace substitutions in the form "search/replace"
func ReplaceSubstrings(s string, replaceList []string, ignoreCase bool) (string, []string) {
	var warnings []string

	for _, entry := range replaceList {
		parts := strings.SplitN(entry, "/", 2)
		if len(parts) != 2 {
			warnings = append(warnings, entry)
			continue
		}

		search := parts[0]
		replace := parts[1]

		if ignoreCase {
			// Use regexp with case-insensitive flag
			re := regexp.MustCompile(`(?i)` + regexp.QuoteMeta(search))
			s = re.ReplaceAllString(s, replace)
		} else {
			s = strings.ReplaceAll(s, search, replace)
		}
	}

	return s, warnings
}

// SearchSubstring returns true if substr is in s (with optional case-insensitivity).
func SearchSubstring(s, substr string, ignoreCase bool) bool {
	if ignoreCase {
		s = strings.ToLower(s)
		substr = strings.ToLower(substr)
	}
	return strings.Contains(s, substr)
}

// FindMatchingLines returns lines containing substr (grep-like)
func FindMatchingLines(s, substr string, ignoreCase bool) []string {
	lines := strings.Split(s, "\n")

	var matches []string

	for _, line := range lines {
		if ignoreCase {
			if strings.Contains(strings.ToLower(line), strings.ToLower(substr)) {
				matches = append(matches, line)
			}
		} else {
			if strings.Contains(line, substr) {
				matches = append(matches, line)
			}
		}
	}

	return matches
}
