# OHP-HTML
Simple HTML overhead projector slides

This project is designed to provide a simple way of displaying church service
slides on a projector screen.

File Purposes
=============

- Cross.png, SolidDirt.png: Welcome slide images
- mpnimport.pike: script for automatic importing of relevant hymns
- ohp.css, oph.js: supporting files for slides.html
- preservice.txt: hymns not yet in database
- projectorwindow.html: Opens a window of size to match projector for testing
- README.md: this file
- requirements.txt: depended libraries for web app deployment
- server.py: server for synchronized slides on multiple devices
- slides.html: main slides content file
- sup.html: handy conversion tool to get superscript numbers

Content Format
==============

This section assumes little knowledge of HTML.

The main content file (slides.html) is a standard HTML5 page, structured to
show one slide at a time. The first nine lines of the file need not be touched
by content editors. The content starts with the first `<section>` tag. The
contents of a slide are contained within the `<section>` and `</section>` tags.

```html
<section><h3>Crown Him
With Many Crowns</h3></section>
<section>
1. Crown Him with many crowns,
the Lamb upon His throne,
Hark! how the heavenly anthem drowns
all music but its own!
</section>
<section>
Awake, my soul, and sing
of Him who died for thee
and hail him as thy matchless King
through all eternity.
</section>
```

In this block, the first slide would contain the hymn title, and the next would
hold the first half of the first verse, and so on. To have a refrain slide, use
`<section class=refrain>` to open instead of a standard `<section>`. It is
still closed with a standard `</section>`.

Other recognized tags and their purposes:

- `<h1>`: Large heading, used in Welcome slide
- `<h3>`: Smaller heading, used for hymn titles
- `<address>`: Large vertically centered text, used for Bible readings
- `<cite>`: Small print in bottom right corner. Used for copyright notices.
- `<aside>`: TBC
- `<img src="imagename.png">`: In-line image
- `<section data-bg="background.png">`: Background image

To remotely switch between Chrome (running these overheads) and LibreOffice
(for backwards compatibility), these bash aliases may be useful:

    alias lo='env DISPLAY=:0.0 wmctrl -a 5.1'
    alias ch='env DISPLAY=:0.0 wmctrl -a Chrome'

Socket.io Server
================

This server allows the slides to be displayed and controlled from any machine
connected to the server. It is a Python 3 script that requires the aiohttp
module to run. Once dependencies are satisfied, simply run:

    python3 server.py
    
in a terminal from the OHP-HTML directory.

TODO: Socket.io to synchronize master(s) with slaves(s). Might also make reload
not reset to start of slides.

MPN Import
==========

Rather than having to type or copy each hymn every time it is needed, it is
possible to recall the entire hymn, with tags, from past use in slides.html.

mpnimport.pike is a Pike script ([interpreter](https://pike.lysator.liu.se/))
that can run in three different modes:
- By default, look at [MPN][1] and create slides automatically.
- With hymn references as arguments, create slides just for those hymns
- With the `list` argument, lists hymns it can find in Git history.

Correct detection of hymns for MPN import depends on their unique IDs. These
should consist of a source identifier and a hymn number, eg "Rej 246" or "PP 3"
or "MP 15", with the space included.

If hymns cannot be found in Git history, a skeleton hymn section is created for
the content editors to enter manually.

Licences
========

The code in this repository is MIT-licensed. Hymn texts are copyright by their
original owners, and their use is governed by the appropriate licenses eg CCLI;
data usage is not covered by the below text.

Copyright (c) 2016, Chris Angelico

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

[1]: http://gideon.kepl.com.au:8000/mpn_read.html#sundaymusic
