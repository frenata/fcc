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
	headers := r.Header
	ip := getIP(headers)
	language := getLanguage(headers)
	os := getOS(headers)

	/*for key, value := range headers {
		log.Printf("key: %s value: %s", key, value)
	}*/

	io.WriteString(w, "Request Headers Microservice\n")
	io.WriteString(w, "Your IP address: "+ip+"\n")
	io.WriteString(w, "Your language: "+language+"\n")
	io.WriteString(w, "Your operating system: "+os+"\n")
}

func getIP(headers http.Header) string {
	possibleKeys := []string{"Remote_Addr", "Client-IP", "X-Forwarded-For"}

	for _, key := range possibleKeys {
		if value := headers.Get(key); value != "" {
			return value
		}
	}

	return "Not Found"
}

func getLanguage(headers http.Header) string {
	language := headers.Get("Accept-Language")
	if language != "" {
		return language
	}

	return "Not Found"
}

func getOS(headers http.Header) string {
	os := headers.Get("User-Agent")
	if os != "" {
		return os
	}

	return "Not Found"
}

func main() {
	// get bound port of host system
	port := os.Getenv("PORT")

	http.HandleFunc("/", requestHeader)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
