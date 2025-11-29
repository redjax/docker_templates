package httplib

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// DecodeJSONResponse decodes a JSON response body into the provided interface
func DecodeJSONResponse(resp *http.Response, v interface{}) error {
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}
	return json.NewDecoder(resp.Body).Decode(v)
}

// ReadResponseBody reads the entire response body and returns it as a byte slice
func ReadResponseBody(resp *http.Response) ([]byte, error) {
	defer resp.Body.Close()
	return io.ReadAll(resp.Body)
}

// CheckStatusCode checks if the response status code is in the acceptable range
func CheckStatusCode(resp *http.Response, acceptableCodes ...int) error {
	if len(acceptableCodes) == 0 {
		acceptableCodes = []int{http.StatusOK}
	}

	for _, code := range acceptableCodes {
		if resp.StatusCode == code {
			return nil
		}
	}

	return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
}

// ResponseHandler provides a fluent interface for handling HTTP responses
type ResponseHandler struct {
	resp *http.Response
	err  error
}

// NewResponseHandler creates a new response handler
func NewResponseHandler(resp *http.Response, err error) *ResponseHandler {
	return &ResponseHandler{resp: resp, err: err}
}

// CheckStatus validates the response status code
func (rh *ResponseHandler) CheckStatus(acceptableCodes ...int) *ResponseHandler {
	if rh.err != nil {
		return rh
	}
	rh.err = CheckStatusCode(rh.resp, acceptableCodes...)
	return rh
}

// DecodeJSON decodes the response body as JSON
func (rh *ResponseHandler) DecodeJSON(v interface{}) error {
	if rh.err != nil {
		return rh.err
	}
	defer rh.resp.Body.Close()
	return json.NewDecoder(rh.resp.Body).Decode(v)
}

// ReadBody reads the response body
func (rh *ResponseHandler) ReadBody() ([]byte, error) {
	if rh.err != nil {
		return nil, rh.err
	}
	defer rh.resp.Body.Close()
	return io.ReadAll(rh.resp.Body)
}

// Error returns any error that occurred during response handling
func (rh *ResponseHandler) Error() error {
	return rh.err
}
