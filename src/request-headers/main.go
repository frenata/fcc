package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

// Converts the passed value to a time and writes a JSON response
// including the natural and unix times.
func requestHeader(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, getHeaders(r.Header))
}

func main() {
	// get bound port of host system
	port := os.Getenv("PORT")

	http.HandleFunc("/", requestHeader)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
