package httplib

import (
	"context"
	"net/http"
)

// HTTPClient is an interface that any HTTP client should implement
// This allows for easy testing and mocking
type HTTPClient interface {
	Do(ctx context.Context, req *http.Request) (*http.Response, error)
}

// Ensure our Client implements the HTTPClient interface
var _ HTTPClient = (*Client)(nil)
