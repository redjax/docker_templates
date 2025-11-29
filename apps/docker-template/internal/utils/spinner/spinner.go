package spinner

import (
	"fmt"
	"time"

	"github.com/briandowns/spinner"
)

// Spinner wraps briandowns/spinner to allow dynamic message updates
type Spinner struct {
	s *spinner.Spinner
}

// NewSpinner creates and starts a new spinner with the given initial message
//
// Usage:
// Start a spinner with sp := spinner.NewSpinner("Message to show while spinning")
//
// Write some other code, then call sp.Stop()
//
// Example:
//
// sp := spinner.NewSpinner("Waiting 3 seconds")
// time.Sleep(3 * time.Second)
// sp.Stop()
//
// Don't forget to call sp.Stop() in if err != nil {} statements
func NewSpinner(message string) *Spinner {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " " + message
	s.Start()
	return &Spinner{s: s}
}

// UpdateMessage changes the spinner's message while it is running
func (sp *Spinner) UpdateMessage(message string) {
	sp.s.Suffix = " " + message
}

// Stop stops the spinner and prints an optional final message on a fresh line
func (sp *Spinner) Stop(finalMessage ...string) {
	sp.s.Stop()
	fmt.Print("\r\033[K") // clear the spinner line
	if len(finalMessage) > 0 {
		fmt.Println(finalMessage[0])
	}
}

// Convenience function: start spinner and return stop function
func StartSpinner(message string) func() {
	sp := NewSpinner(message)
	return func() { sp.Stop() }
}
