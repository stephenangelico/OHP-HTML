let curslide;
function next_slide()
{
	//See if there are any <aside> blocks still hidden. If so,
	//unhide one and that's it.
	let asides = curslide.getElementsByTagName("aside");
	for (let i=0; i<asides.length; ++i) if (!asides[i].classList.contains("current"))
	{
		asides[i].classList.add("current");
		return;
	}
	change_slide("nextSibling");
}

function prev_slide()
{
	//See if there are any visible <aside> blocks. If so,
	//hide one and that's it.
	let asides = curslide.getElementsByTagName("aside");
	for (let i=asides.length-1; i>=0; --i) if (asides[i].classList.contains("current"))
	{
		asides[i].classList.remove("current");
		return;
	}
	change_slide("previousSibling");
}

function change_slide(sib)
{
	let slide = curslide, lastslide = curslide;
	do
	{
		slide = slide[sib];
		if (!slide) return; //End of slides, stop
	} while (slide.nodeName != "SECTION");
	lastslide.classList.remove("current");
	slide.classList.add("current");
	curslide = slide;
	//Autoplay videos on arrival
	for (let v of slide.getElementsByTagName("video")) v.play();
	//And pause on departure (doesn't rewind though)
	for (let v of lastslide.getElementsByTagName("video")) v.pause();
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
			slide.getElementsByTagName("video").foreach(v => v.pause());
			break;
		default:
			console.log(event);
			break;
	}
}

function findfirst()
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
}
