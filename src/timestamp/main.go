package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
)

func hello(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Hello World")
}

func main() {
	port, err := strconv.Atoi(os.Getenv("PORT"))
	if err != nil {
		log.Fatal("host port not fount")
	}
	http.HandleFunc("/", hello)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
