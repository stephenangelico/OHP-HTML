let curslide, slideidx = 0;
let announce_pos = (n) => null; //Proclaim to the websocket, if we have one.

function next_slide()
{
	//See if there are any <aside> blocks still hidden. If so,
	//unhide one and that's it.
	let asides = curslide.getElementsByTagName("aside");
	for (let i=0; i<asides.length; ++i) if (!asides[i].classList.contains("current"))
	{
		asides[i].classList.add("current");
		announce_pos(++slideidx);
		return;
	}
	if (change_slide("nextSibling")) announce_pos(++slideidx);
}

function prev_slide()
{
	//See if there are any visible <aside> blocks. If so,
	//hide one and that's it.
	let asides = curslide.getElementsByTagName("aside");
	for (let i=asides.length-1; i>=0; --i) if (asides[i].classList.contains("current"))
	{
		asides[i].classList.remove("current");
		announce_pos(--slideidx);
		return;
	}
	if (change_slide("previousSibling")) announce_pos(--slideidx);
}

function change_slide(sib)
{
	let slide = curslide, lastslide = curslide;
	do
	{
		slide = slide[sib];
		if (!slide) return false; //End of slides, stop
	} while (slide.nodeName != "SECTION");
	lastslide.classList.remove("current");
	slide.classList.add("current");
	curslide = slide;
	//Autoplay videos on arrival
	for (let v of slide.getElementsByTagName("video")) v.play();
	//And pause on departure (doesn't rewind though)
	for (let v of lastslide.getElementsByTagName("video")) v.pause();
	return true;
}

function keypress(event)
{
	switch (event.keyIdentifier || event.key) /* keyIdentifier is NOT OFFICIALLY SUPPORTED */
	{
		case "U+0020":
		case " ":
		case "Right":
		case "ArrowRight":
		case "PageDown":
			next_slide();
			break;
		case "ArrowLeft":
		case "Left":
		case "PageUp":
			prev_slide();
			break;
		case "U+00BE": //Screen-blank
		case ".":
			curslide.classList.toggle("current");
			//Use the Blank button to stop videos
			curslide.getElementsByTagName("video").foreach(v => v.pause());
			break;
		default:
			console.log(event);
			break;
	}
}

function setup()
{
	let sections = document.getElementsByTagName("section");
	curslide = sections[0];
	curslide.classList.add("current");
	for (let sec of sections)
	{
		if (sec.classList.contains("showcase"))
			sec.innerHTML = '<div style="background-image: url(' + sec.innerHTML + ')"></div>';
		if (sec.dataset.bg)
		{
			sec.style.backgroundImage = 'url(' + sec.dataset.bg + ')';
			sec.classList.add("bgimg"); //Apply other styles there, for simplicity
		}
	}
	if (window.socketid)
	{
		//We were given a socket ID, which almost certainly means we're running off the
		//synchronization server. Establish a websocket connection and maintain position.
		const protocol = window.location.protocol == "https:" ? "wss://" : "ws://";
		const socket = new WebSocket(protocol + window.location.host + "/ws");
		let active = false;
		socket.onopen = () => socket.send(JSON.stringify({type: "socketid", data: window.socketid}))
		announce_pos = (n) => active && socket.send(JSON.stringify({type: "setpos", data: n}))
		socket.onmessage = (ev) => {
			const data = JSON.parse(ev.data);
			if (data.type !== "position") return; //Only one recognized message so far.
			let offset = data.data - slideidx;
			console.log("I'm at", slideidx, "and need to go to", data.data, "so we move", offset);
			//While we're updating position, don't announce to other clients.
			active = false;
			if (offset > 0) while (offset--) next_slide();
			else if (offset < 0) while (offset++) prev_slide();
			//We only begin announcing once we've heard from the server for the first time.
			active = true;
		};
	}
}
