package main

import (
	"encoding/json"
	"net/http"
)

type HeadersResponse struct {
	Ip   *string `json:"ipaddress"`
	Lang *string `json:"language"`
	Os   *string `json:"software"`
}

func (hr HeadersResponse) String() string {
	json, _ := json.MarshalIndent(hr, "", "    ")
	return string(json)
}

func getHeaders(headers http.Header) string {
	ip := getIP(headers)
	lang := getLanguage(headers)
	os := getOS(headers)

	return HeadersResponse{ip, lang, os}.String()
	//return fmt.Sprintf("Your IP address: %s\nYour language: %s\nYour OS: %s\n",
	//ip, lang, os)
}

func getIP(headers http.Header) *string {
	possibleKeys := []string{"Remote_Addr", "Client-IP", "X-Forwarded-For"}

	for _, key := range possibleKeys {
		if ip := headers.Get(key); ip != "" {
			return &ip
		}
	}

	return nil
}

func getLanguage(headers http.Header) *string {
	language := headers.Get("Accept-Language")
	if language != "" {
		return &language
	}

	return nil
}

func getOS(headers http.Header) *string {
	os := headers.Get("User-Agent")
	if os != "" {
		return &os
	}

	return nil
}
