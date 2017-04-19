package main

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

// JSON response
type TimeResponse struct {
	Unix    *string `json:"unix"`
	Natural *string `json:"natural"`
}

// From a time, generate a new JSON response
func NewTimeResponse(t time.Time) TimeResponse {
	natural := t.Format("2 January 2006")
	unix := strconv.FormatInt(t.Unix(), 10)

	return TimeResponse{&unix, &natural}
}

// Converts the passed value to a time and writes a JSON response
// including the natural and unix times.
func timestamp(w http.ResponseWriter, r *http.Request) {
	if r.URL.String() == "/" {
		io.WriteString(w, "Send a requested date or timestamp to /ts/your-request to receive a JSON response back with both the unix epoch and human readable time")
		return
	}

	// process URL to get request
	request := r.URL.String()[1:]
	if strings.HasSuffix(request, "/") {
		request = request[:len(request)-1]
	}
	request = strings.Replace(request, "%20", " ", -1)
	log.Println("request: " + request)

	// get a time from the request
	reqTime, err := getTime(request)

	// create response JSON
	response := TimeResponse{}
	if err == nil {
		response = NewTimeResponse(*reqTime)
	}
	json, _ := json.MarshalIndent(response, "", "    ")

	// write the JSON
	io.WriteString(w, string(json))
}

func getTime(request string) (*time.Time, error) {
	layouts := []string{
		"January 2 2006",
		"January 2, 2006",
		"2 January 2006",
		"2 Jan 2006",
		"Jan 2, 2006",
		"01/02/06",
	}

	// First check if it's a Unix epoch
	epoch, err := strconv.ParseInt(request, 10, 64)
	if err == nil {
		timestamp := time.Unix(epoch, 0)
		return &timestamp, nil
	}

	// Then try the human formats
	for _, layout := range layouts {
		timestamp, err := time.Parse(layout, request)
		if err == nil {
			return &timestamp, nil
		}
	}

	return nil, errors.New("unrecognized time format")
}

func main() {
	port := os.Getenv("PORT")

	http.HandleFunc("/", timestamp)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
