package main

import (
	"encoding/json"
	"net/http"
	"strings"
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
}

func getIP(headers http.Header) *string {
	possibleKeys := []string{"Remote_Addr", "Client-IP", "X-Forwarded-For"}

	for _, key := range possibleKeys {
		if ip := headers.Get(key); ip != "" {
			comma := strings.Index(ip, ",")
			if comma != -1 {
				ip = ip[:comma]
			}
			return &ip
		}
	}

	return nil
}

func getLanguage(headers http.Header) *string {
	language := headers.Get("Accept-Language")
	if language != "" {
		comma := strings.Index(language, ",")
		language = language[:comma]
		return &language
	}

	return nil
}

func getOS(headers http.Header) *string {
	os := headers.Get("User-Agent")
	if os != "" {
		open := strings.Index(os, "(")
		close := strings.Index(os, ")")
		os = os[open+1 : close]
		return &os
	}

	return nil
}
