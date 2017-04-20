package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

const howto string = `
Send a requested date or timestamp to /your-request to receive a JSON response back with both the unix epoch and human readable time.

For example:
https://timestamp-go.herokuapp.com/November 5, 2017

will deliver the response:

{
	"unix": "1509840000",
	"natural": "5 November 2017"
}

Several date formats are supported, try experimenting!

Source code can be found at:
https://github.com/frenata/fcc/tree/master/timestamp/go
`

// Converts the passed value to a time and writes a JSON response
// including the natural and unix times.
func timestamp(w http.ResponseWriter, r *http.Request) {
	// write the instructions
	if r.URL.String() == "/" {
		io.WriteString(w, howto)
		return
	}

	// write the JSON
	response := GetTimeResponse(r.URL.String()[1:]).String()
	io.WriteString(w, response)
}

func main() {
	// get bound port of host system
	port := os.Getenv("PORT")

	http.HandleFunc("/", timestamp)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
