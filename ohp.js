var curslide;
function keypress(event)
{
	var slide = curslide, lastslide = curslide;
	var sib = "previousSibling";
	switch (event.keyIdentifier || event.key) /* keyIdentifier is NOT OFFICIALLY SUPPORTED */
	{
		case "U+0020":
		case " ":
		case "Right":
		case "ArrowRight":
		case "PageDown":
			sib = "nextSibling";
			//See if there are any <aside> blocks still hidden. If so,
			//unhide one and that's it.
			var asides = slide.getElementsByTagName("aside");
			for (var i=0; i<asides.length; ++i) if (!asides[i].classList.contains("current"))
			{
				asides[i].classList.add("current");
				return;
			}
			break;
		case "ArrowLeft":
		case "Left":
		case "PageUp":
			//See if there are any visible <aside> blocks. If so,
			//hide one and that's it.
			var asides = slide.getElementsByTagName("aside");
			for (var i=asides.length-1; i>=0; --i) if (asides[i].classList.contains("current"))
			{
				asides[i].classList.remove("current");
				return;
			}
			break;
		case "U+00BE": //Screen-blank
		case ".":
			slide.classList.toggle("current");
			//Use the Blank button to stop videos
			var videos = slide.getElementsByTagName("video");
			for (var i=0; i<videos.length; ++i)
				videos[i].pause();
			return;
		default:
			console.log(event);
			return;
	}
	do
	{
		slide = slide[sib];
		if (!slide) return; //End of slides, stop
	} while (slide.nodeName != "SECTION");
	lastslide.classList.remove("current");
	slide.classList.add("current");
	curslide = slide;
	//Autoplay videos on arrival
	var videos = slide.getElementsByTagName("video");
	for (var i=0; i<videos.length; ++i)
		videos[i].play();
	//And pause on departure (doesn't rewind though)
	var videos = lastslide.getElementsByTagName("video");
	for (var i=0; i<videos.length; ++i)
		videos[i].pause();
}

function findfirst()
{
	var sections = document.getElementsByTagName("section");
	curslide = sections[0];
	curslide.classList.add("current");
	for (var i=0; i < sections.length; ++i)
	{
		var sec = sections[i];
		if (sec.classList.contains("showcase"))
			sec.innerHTML = '<div style="background-image: url(' + sec.innerHTML + ')"></div>';
		if (sec.dataset.bg)
		{
			sec.style.backgroundImage = 'url(' + sec.dataset.bg + ')';
			sec.classList.add("bgimg"); //Apply other styles there, for simplicity
		}
	}
}