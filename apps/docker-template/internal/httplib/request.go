package httplib

import (
	"context"
	"io"
	"net/http"
	"net/url"
)

// RequestBuilder provides a fluent interface for building HTTP requests
type RequestBuilder struct {
	method  string
	baseURL string
	path    string
	query   url.Values
	headers map[string]string
	body    io.Reader
	ctx     context.Context
}

// NewRequest creates a new RequestBuilder with the given method and base URL
func NewRequest(method, baseURL string) *RequestBuilder {
	return &RequestBuilder{
		method:  method,
		baseURL: baseURL,
		query:   url.Values{},
		headers: make(map[string]string),
		ctx:     context.Background(),
	}
}

// NewGetRequest creates a new GET request builder
func NewGetRequest(baseURL string) *RequestBuilder {
	return NewRequest(http.MethodGet, baseURL)
}

// NewPostRequest creates a new POST request builder
func NewPostRequest(baseURL string) *RequestBuilder {
	return NewRequest(http.MethodPost, baseURL)
}

// Path sets the URL path
func (rb *RequestBuilder) Path(path string) *RequestBuilder {
	rb.path = path
	return rb
}

// QueryParam adds a query parameter
func (rb *RequestBuilder) QueryParam(key, value string) *RequestBuilder {
	rb.query.Add(key, value)
	return rb
}

// QueryParams adds multiple query parameters
func (rb *RequestBuilder) QueryParams(params map[string]string) *RequestBuilder {
	for key, value := range params {
		rb.query.Add(key, value)
	}
	return rb
}

// Header adds a header
func (rb *RequestBuilder) Header(key, value string) *RequestBuilder {
	rb.headers[key] = value
	return rb
}

// Headers adds multiple headers
func (rb *RequestBuilder) Headers(headers map[string]string) *RequestBuilder {
	for key, value := range headers {
		rb.headers[key] = value
	}
	return rb
}

// Body sets the request body
func (rb *RequestBuilder) Body(body io.Reader) *RequestBuilder {
	rb.body = body
	return rb
}

// Context sets the context for the request
func (rb *RequestBuilder) Context(ctx context.Context) *RequestBuilder {
	rb.ctx = ctx
	return rb
}

// Build constructs the final http.Request
func (rb *RequestBuilder) Build() (*http.Request, error) {
	fullURL := rb.baseURL
	if rb.path != "" {
		fullURL += rb.path
	}
	if len(rb.query) > 0 {
		fullURL += "?" + rb.query.Encode()
	}

	req, err := http.NewRequestWithContext(rb.ctx, rb.method, fullURL, rb.body)
	if err != nil {
		return nil, err
	}

	for key, value := range rb.headers {
		req.Header.Set(key, value)
	}

	return req, nil
}

// BuildSimpleGetRequest is a helper to quickly build a GET request with query params
func BuildSimpleGetRequest(ctx context.Context, baseURL string, params url.Values) (*http.Request, error) {
	fullURL := baseURL
	if len(params) > 0 {
		fullURL += "?" + params.Encode()
	}
	return http.NewRequestWithContext(ctx, http.MethodGet, fullURL, nil)
}
