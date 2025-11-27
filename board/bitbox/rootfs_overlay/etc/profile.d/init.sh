#!/usr/bin/sh

# set terminal type to xterm-256color for serial console
if [ $(tty) = '/dev/ttyS0' ]; then
  export TERM='xterm-256color'
fi

cd ~

