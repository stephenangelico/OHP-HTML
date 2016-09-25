# OHP-HTML
Simple HTML overhead projector slides

To remotely switch between Chrome (running these overheads) and LibreOffice
(for backwards compatibility), these bash aliases may be useful:

    alias lo='env DISPLAY=:0.0 wmctrl -a 5.1'
    alias ch='env DISPLAY=:0.0 wmctrl -a Chrome'

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
