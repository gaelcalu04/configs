#!/bin/sh   

list=( "git" "vim" "zsh" "python-pip" "python-smbus" "python-serial" "cmake" "libusb-1.0" "minicom")   
for element in "${list[@]}"    
    do
	sudo apt-get install -y $element
    done
