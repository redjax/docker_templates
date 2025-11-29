package httplib

import (
	"context"
	"math"
	"net/http"
	"time"
)

// RetryConfig holds retry configuration for the HTTP client
type RetryConfig struct {
	MaxRetries      int
	InitialInterval time.Duration
	MaxInterval     time.Duration
	// Optional: function to decide if retry is needed for a given response or error
	RetryIf func(resp *http.Response, err error) bool
}

// DefaultRetryConfig returns a sensible default retry configuration
func DefaultRetryConfig() RetryConfig {
	return RetryConfig{
		MaxRetries:      3,
		InitialInterval: 500 * time.Millisecond,
		MaxInterval:     10 * time.Second,
		RetryIf:         nil, // use default retry logic
	}
}

// Client is an HTTP client with retry logic and additional utilities
type Client struct {
	httpClient  *http.Client
	retryConfig RetryConfig
}

// NewClient creates a new HTTP client with the given configuration
// If httpClient is nil, a default client with 10s timeout will be used
func NewClient(httpClient *http.Client, retryConfig RetryConfig) *Client {
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 10 * time.Second}
	}
	return &Client{
		httpClient:  httpClient,
		retryConfig: retryConfig,
	}
}

// NewDefaultClient creates a new HTTP client with default retry configuration
func NewDefaultClient() *Client {
	return NewClient(nil, DefaultRetryConfig())
}

// Do executes the HTTP request with retry logic
func (c *Client) Do(ctx context.Context, req *http.Request) (*http.Response, error) {
	var resp *http.Response
	var err error

	for attempt := 0; attempt <= c.retryConfig.MaxRetries; attempt++ {
		if attempt > 0 {
			wait := c.backoff(attempt)
			select {
			case <-time.After(wait):
				// proceed to retry
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		}

		resp, err = c.httpClient.Do(req.WithContext(ctx))

		if !c.shouldRetry(resp, err) {
			return resp, err
		}

		// Close response body before retrying if not nil
		if resp != nil {
			resp.Body.Close()
		}
	}
	// Return last response/error after retries exhausted
	return resp, err
}

// backoff calculates wait time for given attempt with tapered exponential backoff
func (c *Client) backoff(attempt int) time.Duration {
	interval := float64(c.retryConfig.InitialInterval) * math.Pow(2, float64(attempt-1))
	if interval > float64(c.retryConfig.MaxInterval) {
		interval = float64(c.retryConfig.MaxInterval)
	}
	return time.Duration(interval)
}

// shouldRetry determines if a request should be retried
// By default, retry on network error or status codes 5xx
func (c *Client) shouldRetry(resp *http.Response, err error) bool {
	if c.retryConfig.RetryIf != nil {
		return c.retryConfig.RetryIf(resp, err)
	}
	if err != nil {
		return true
	}
	if resp != nil && resp.StatusCode >= 500 {
		return true
	}
	return false
}
