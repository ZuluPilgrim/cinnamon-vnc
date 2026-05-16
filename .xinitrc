#!/bin/bash
# .xinitrc — X session startup file for the desktop user
# This file is executed by xinit/startx when an X session begins.
# It launches the Cinnamon desktop environment as the session window manager.
exec /usr/bin/cinnamon-session
