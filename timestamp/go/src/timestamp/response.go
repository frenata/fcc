package main

import (
	"encoding/json"
	"errors"
	"log"
	"strconv"
	"strings"
	"time"
)

// possible layouts for parsing date
var layouts = []string{
	"January 2 2006",
	"January 2, 2006",
	"2 January 2006",
	"2January2006",
	"2 Jan 2006",
	"2Jan2006",
	"2Jan06",
	"Jan 2, 2006",
	"01/02/06",
	"02-Jan-06",
	"02-01-06",
	"2006-01-02",
	"2006/01/02",
	"20060102",
}

// TimeResponse represents a JSON response
type TimeResponse struct {
	Unix    *string `json:"unix"`
	Natural *string `json:"natural"`
}

// NewTimeResponse generates a JSON response from a given time
func NewTimeResponse(t time.Time) TimeResponse {
	natural := t.Format("2 January 2006")
	unix := strconv.FormatInt(t.Unix(), 10)

	return TimeResponse{&unix, &natural}
}

// Pretty prints a TimeResponse in JSON format
func (tr TimeResponse) String() string {
	json, _ := json.MarshalIndent(tr, "", "    ")
	return string(json)
}

// Given a URL request, generates a JSON response string
func GetTimeResponse(request string) TimeResponse {
	// process URL to get request
	if strings.HasSuffix(request, "/") {
		request = request[:len(request)-1]
	}
	request = strings.Replace(request, "%20", " ", -1)
	log.Println("request: " + request)

	// get a time from the request
	reqTime, err := getTime(request)
	if err != nil {
		return TimeResponse{}
	}
	return NewTimeResponse(*reqTime)
}

// Given a request, try to parse it into a date
// Returns an error if no way to parse it is found
func getTime(request string) (*time.Time, error) {
	// First try the human formats
	for _, layout := range layouts {
		timestamp, err := time.Parse(layout, request)
		if err == nil {
			return &timestamp, nil
		}
	}

	// Then check if it's a Unix epoch
	epoch, err := strconv.ParseInt(request, 10, 64)
	if err == nil {
		timestamp := time.Unix(epoch, 0)
		return &timestamp, nil
	}

	return nil, errors.New("unrecognized time format")
}
