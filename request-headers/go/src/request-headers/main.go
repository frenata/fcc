package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

func requestHeader(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, GetHeaders(r.Header))
}

func main() {
	// get bound port of host system
	port := os.Getenv("PORT")

	http.HandleFunc("/", requestHeader)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
