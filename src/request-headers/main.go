package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

// Converts the passed value to a time and writes a JSON response
// including the natural and unix times.
func headers(w http.ResponseWriter, r *http.Request) {
	head := r.Header
	log.Println(head.Get("Remote_Addr"))

	for key, value := range head {
		log.Printf("key: %s value: %s", key, value)
	}

	io.WriteString(w, "Request Headers Microservice")
}

func main() {
	// get bound port of host system
	port := os.Getenv("PORT")

	http.HandleFunc("/", headers)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
