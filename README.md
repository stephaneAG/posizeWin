# posizeWin
little script for Ubuntu replacing the built-in keyboard shortcuts for window resizing &amp; repositionning

#### dependencies
xdotool # sudo apt-get install xdotool

#### what for ?

on Ubuntu 14.04 ( & maybe other versions ), when the mouse is used with the screen corners to set a window to use one-fourth of the screen & set its position, afterwhat the standard keyboard shortcuts that are normally used for further window handling doesn't work.

the script bypasses whatever the built-in implementation is doing by relying on the so-useful "xdotool" utility

by calling the script & specifying one or more argument, we can test the effects of the provided xdotool commands on a system, generate a list of the available entries ( each having a Name, Command & Keys field ) for quick copy/paste, or even directly install all or specific entries in the gsettings GUI panel ( by using its cli utility ), with or without directly settings the keys for any particular shortcut

the external <..>_dict file is used to store the mapping of the entries Name/Command/Keys for a particular system ( -> aka mine ;p ) but should be helpful on many ( actually, these'd easily look somewhat "standard" in the way I chose the keys .. )

#### usage examples
./stag_psresWin_script_exec.sh help
./stag_psresWin_script_exec.sh install all
./stag_psresWin_script_exec.sh install top right bottomleft
