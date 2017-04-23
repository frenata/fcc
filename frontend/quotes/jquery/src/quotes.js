// document.ready
$(() => getQuote());

// retrieve a quote from the API
function getQuote() {
	let trumpAPI = "https://api.whatdoestrumpthink.com/api/v1/quotes/random/";

	$.getJSON( trumpAPI, response => {
		let text = response.message;
		let by = "Trump?!";
		setQuote(text,by);
	});

}

// write the quote to the page and to the twitter 'share intent'
function setQuote(text, by){
	$("#quote").html(text);
	$("#cite").html("- " + by);

	document.querySelector("#tweet")
		.setAttribute("href", 
			"https://twitter.com/share?text=" + 
			fixedEncodeURIComponent(text.replace(/<\/?p>/g, "")) + 
			" -" + by);
}

// from MDN page on EncodeURIComponent
function fixedEncodeURIComponent(str) {
	return encodeURIComponent(str).replace(/[!'()*]/g, 
		c => "%" + c.charCodeAt(0).toString(16));
}

// pull new quote on button click
$("#new-quote").click(() => getQuote());

