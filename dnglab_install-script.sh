#!/bin/bash
# AUTHOR: mattF11
# VERSION: 1.0
# DESCRIPTION: dnglab script to perform installation and basic functions

echo "
____________________________
|			   |
|      |      |            |
|      |      | _ |        |
|     _||_  _ | _||_       |
|    |_|| ||_|||_||_|      |
|           _|             |
|__________________________|
"

####################################################################################
# DIRECTORY LIST
a="$HOME"
b="$HOME/dnglab"
c="$HOME/dnglab/target/release"
###################################################################################

# Selection
echo "$USER, select the action (1/2/3)
1. Install dnglab
2. DNG-Convertion
3. Exit
: "

read selection

# 1.1 check if string is inserted
if [[ -z "$selection" ]]; then
    echo "ERROR: wrong insertion type, insert an integer"
else
    echo "Insertion type: CORRECT"
fi

#################################################################################
# 1.1.0/1.2.0 available options:
case $selection in
    
    1|1.|Install|dnglab)
        echo "Selected: Install dnglab"

        cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }

        if [[ -d "$b" ]]; then
            echo "Abort installation... dnglab already installed"
            exit 0
        else
            echo "Starting installation process..."

            git clone https://github.com/dnglab/dnglab.git \
                || { echo "ERROR: git clone failed"; exit 1; }

            cd "$b" || { echo "ERROR: cannot cd into $b"; exit 1; }
            cargo build --release || { echo "ERROR: cargo build failed"; exit 1; }

            echo "Do you want to add dnglab to system PATH? (Y/N):"
            read select
        
            if [[ "$select" == "Y" ]]; then
                echo "Y: selected, adding dnglab to PATH"
                cd "$c" || { echo "ERROR: cannot cd into $c"; exit 1; }
                DIR_TO_ADD="$(pwd)"

                # add to PATH only if not already present
                if ! grep -Fxq "export PATH=\"\$PATH:$DIR_TO_ADD\"" "$HOME/.bashrc"; then
                    echo "export PATH=\"\$PATH:$DIR_TO_ADD\"" >> "$HOME/.bashrc"
                fi

                echo "dnglab added to PATH permanently"
                echo "Restart terminal or run: source ~/.bashrc"
                exit 0
            else
                echo "N: selected, actions finished"
                exit 1
            fi
        fi
        ;;


#2.0 selection2
    2|2.|DNG|dng)
        echo "Selected: DNG-Convertion"
        echo "Select (1/2):
1. Insert folder name
2. Insert file name
: "
        read selection2
        if [[ -z "$selection2" ]]
		then	
        	echo "ERROR: wrong insertion type, insert an integer"
    	    exit 1
				else
            echo "Insertion type: CORRECT"
   	     fi
                   
        case $selection2 in

            1|1.)
                cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }

                echo "Search folder/directory:"
                read folder

                # Case-insensitive search
                find . -type d -iname "*${folder}*" > dnglab.txt
                i=0
        
                while read line
			do  
                    echo "[$i] $line"
                    ris[$i]="$line"
                    ((i++))
		    
                done < dnglab.txt

		
                if [[ "$i" -eq "0" ]]
		then    
                    echo "Directory not found"
                    exit 1		    
                else
                    echo "Directory found"
                    echo "Select a directory/folder(n):"
                    read dir

                    selection="${ris[$dir]}"
                    echo "$dir: "$selection""

                    echo "Convert the entire directory(1=yes / 2=no)?"
                    read f1

                    if [[ "$f1" != "1" ]]
		    then
                        echo "no:action cancelled"
                        exit 0
                    else
                        echo "yes:directory conversion selected"

                        echo "Do you want to copy RAW file into DNG(1=yes / 2=no)?"
                        read f1_1

                        shopt -s nullglob #if file not found, empty string 
                        for file in "$selection"/*
			do
                            if [[ "$f1_1" == "1" ]]
			    then
                                cp "$file" "$file.raw"
                            fi
                            dnglab convert "$file" "$file.DNG"
                        done
                        shopt -u nullglob

                        echo "Directory converted"
                        exit 0
                    fi
                fi
                ;;
        
            2|2.|file|name)
                echo "Enter file name:"
                read f2

                echo "Converting..."
                dnglab convert "$f2" "$f2.DNG" || { echo "ERROR: conversion not completed"; exit 1; }

                echo "Conversion process completed"
                find . -type f -iname "*.DNG"
                exit 0
                ;;

            *)
                echo "ERROR: not found"
                exit 1
                ;;
        esac
        ;;

    3|3.|Exit)
        echo "Exit"
        exit 0
        ;;

    *)
        echo "ERROR: not found"
exit 1
