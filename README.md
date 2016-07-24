# OHP-HTML
Simple HTML overhead projector slides

To remotely switch between Chrome (running these overheads) and LibreOffice
(for backwards compatibility), these bash aliases may be useful:
    alias lo='env DISPLAY=:0.0 wmctrl -a 5.1'
    alias ch='env DISPLAY=:0.0 wmctrl -a Chrome'

TODO: Some sort of macro system that, in a commit hook, translates hymn refs
into actual hymn texts, using an ancillary file - probably a YAMLish format.
