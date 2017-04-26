Random technical notes
======================

File Purposes
-------------

- AshburtonHymnal.md: Disambiguation file for hymns/songs not in a hymnbook
- Cross.png, SolidDirt.png: Welcome slide images
- mpnimport.pike: script for automatic importing of relevant hymns
- ohp.css, oph.js: supporting files for slides.html
- preservice.txt: hymns not yet in database
- projectorwindow.html: Opens a window of size to match projector for testing
- README.md: README. 'Nuff said.
- requirements.txt: depended libraries for web app deployment
- server.py: server for synchronized slides on multiple devices
- slides.html: main slides content file
- sup.html: handy conversion tool to get superscript numbers
- TechNotes.md: This file

Handy tools
-----------

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
