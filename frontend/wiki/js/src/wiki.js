// pull from the API on clicking search or pressing enter in input
document.querySelector("#query").addEventListener("submit", 
	(e) => {
		getWiki(document.querySelector("#query input").value);
		e.preventDefault();
	}
	,false);

// open random page when clicking "Random" button
document.querySelector("#random-btn").addEventListener("click",
	(e) => {
		window.open("https://en.wikipedia.org/wiki/Special:Random");
		e.preventDefault();
	}
	,false);

// pull from the wikipedia API
function getWiki(search) {
	let url = "https://en.wikipedia.org/w/api.php?" +
		"action=opensearch&format=json&origin=*&search=" + search;
	
	getJSON(url, (err,data) => 
		err != null ?
			alert(err) :
			writeWikiResults(data[1],data[2],data[3])
	);
}

// write the results of the API pull to the page
function writeWikiResults(title,description,link){
	clearResults();

	title.forEach((_,i) =>
		appendResult(title[i],description[i],link[i]));
}

// remove any old results
function clearResults() {
	document.querySelector("#results").innerHTML = "";
}

// build a div containing a result and add it to the list
function appendResult(title,description,link) {
	document.querySelector("#results").innerHTML += 
		`<a target="_blank" href="${link}" class="result">
			<div>
				<h3>${title}</h3>
				<p>${description}</p>
			</div>
		</a>`;
}

// pull from a JSON API
function getJSON(url, callback) {
	let xhr = new XMLHttpRequest();

	xhr.open("GET", url, true);
	xhr.responseType = "json";
	xhr.onload = () => 
		xhr.status == 200 ?
			callback(null, xhr.response) :
			callback(status);
	xhr.send();
}
