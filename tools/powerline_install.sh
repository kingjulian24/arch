#!/bin/bash
cd /tmp 

POWERLINE_FONTS="https://github.com/powerline/fonts.git"
POWERLINE_SYMBOLS="https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf"
POWERLINE_CONF="https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf"

pip install powerline-status

curl -L $POWERLINE_SYMBOLS -o /usr/share/fonts/PowerlineSymbols.otf
curl -L $POWERLINE_CONF -o /etc/fonts/conf.d/11-powerline-symbols.conf

git clone --depth=1 $POWERLINE_FONTS /tmp/fonts
mv /tmp/fonts/* /usr/share/fonts/

fc-cache -vf /usr/share/fonts
