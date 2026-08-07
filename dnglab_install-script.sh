#!/bin/bash
# AUTHOR: mattF11
# DESCRIPTION: dnglab script to perform installation and basic functions
####################################################################################
# DIRECTORY LIST
a="$HOME"
b="$HOME/dnglab"
c="$HOME/dnglab/target/release"
#####################################################################################
# set -euo pipefail = -e stop script if command fails, -u uninitialized variabile error, -o pipefail if pipeline fails,script fails
# fix the dependancies skipped,it works well but now is placed inside the directory check,which isn't the right thing for it
#set -euo pipefail
function menu_function
{
# Selection menu
echo "$USER, select the action (1/2/3)
1. Install dnglab
2. DNG-Conversion
3. Exit
: "

read selection

# 1.1 check if string is inserted
if [[ -z "$selection" ]]
then
    echo "ERROR: wrong insertion type, insert an integer"
else
    echo "Insertion type: CORRECT"
fi
}

# 1.2 installing dnglab from the official github page
set -euo pipefail
function git_function
{
    if [[ -d "$b" ]]
    then
        echo "Abort installation... dnglab already installed"
        exit 0
    else
        echo "Starting installation process..."

        git clone https://github.com/dnglab/dnglab.git  || { echo "ERROR: git clone failed"; exit 1; }

        cd "$b" || { echo "ERROR: cannot cd into $b"; exit 1; }
        cargo build --release || { echo "ERROR: cargo build failed"; exit 1; }

        echo "Do you want to add dnglab to system PATH? (Y/N):"
        read select
        
        if [[ "$select" == "Y" ]]
	then
            echo "Y: selected, adding dnglab to PATH"
            cd "$c" || { echo "ERROR: cannot cd into $c"; exit 1; }
            DIR="$(pwd)"

            # add to PATH only if not already present
            if ! grep -q "$DIR" "$HOME/.bashrc"
	    then
		echo "export PATH=\"\$PATH:$DIR\"" >> "$HOME/.bashrc"
	    fi


            echo "dnglab added to PATH permanently"
            echo "start a terminal or run: source ~/.bashrc"
            exit 0
        else
            echo "N:selected,actions finished"
            exit 1
        fi
    fi
}


# 1.3 available options
#call the menu
menu_function
    
case $selection in
    
    1|1.|Install|dnglab)
        echo "Selected: Install dnglab"

        cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }

	####################################################################################
	#DEPENDANCIES(openSUSE tumbleweed/leap,debian,fedora)
	#openSUSE
	function openSUSE_function
	{
	    if [[ "${EUID:-$(id -u)}" -ne 0 ]]
	    then
		SUDO=(sudo)
	    else
		SUDO=()
	    fi

	    ZYPPER_PACKAGES=(
		rust
		cargo
	    )
	    "${SUDO[@]}" zypper --non-interactive install --no-recommends "${ZYPPER_PACKAGES[@]}"
	    return 0
	}


	#fedora
	function fedora_function
	{
	    if [[ "${EUID:-$(id -u)}" -ne 0 ]]
	    then
		SUDO=(sudo)
	    else
		SUDO=()
	    fi

	    DNF_PACKAGES=(
		rust
		cargo
	    )
	    "${SUDO[@]}" dnf install -y --setopt=install_weak_deps=False "${DNF_PACKAGES[@]}"
	    return 0
	}


	#debian
	function debian_function
	{
	    if [[ "${EUID:-$(id -u)}" -ne 0 ]]
	    then
		SUDO=(sudo)
	    else
		SUDO=()
	    fi

	    APT_PACKAGES=(
		#rust
		cargo
	    )
	    "${SUDO[@]}" apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
	    return 0
	}


	#ubuntu
	function ubuntu_function
	{
	    if [[ "${EUID:-$(id -u)}" -ne 0 ]]
	    then
		SUDO=(sudo)
	    else
		SUDO=()
	    fi

	    APT_PACKAGES=(
		#rust
		cargo
	    )
	    "${SUDO[@]}" apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
	    return 0
	}
	########################################################################################


	########################################################################################
	# DISTRO NAME
	#source /etc/os-release
	#distro="$ID"
	#searching the distro name: grep distro id from /etc/os-relase,then cut
	#distro=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '""')
	# distro and ID
	distro=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
	ID="$distro"
	
	# a case should make adding the immutable distros simpler,a function for them as well.
	case "$ID" in
	    openSUSE-tumbleweed|opensuse-tumbleweed|openSUSE-leap|opensuse-leap)
		echo "openSUSE Tumbleweed/Leap detected"
		#exec openSUSE tumbleweed/leap  function
		openSUSE_function
		git_function
		exit 0
		;;
	    
	    fedora|Fedora)
		echo "Fedora detected"
		#exec Fedora function
		fedora_function
		git_function
		exit 0
		;;
	    
	    debian|Debian)
		echo "Debian detected"
		#exec Debian function
		debian_function
		git_function
		exit 0
		;;
	    
	    ubuntu|Ubuntu)
		echo "Ubuntu detected"
		#exec Ubuntu function
		ubuntu_function
		git_function
		exit 0
		;;
	    
	    #if none of them
	    *)
		echo "Unsupported distro: $distro"
		exit 1
		;;
	esac
	;;
    ###############################################################################################
    
    # 2.0 selection n2
    2|2.|DNG|dng)
        echo "Selected: DNG-Convertion"
        echo "Select (1/2):
1. Insert folder name
2. Insert file name
: "

	#remember to add a check to see if the PWD is the directory i want to work with or not
	# i wasted a lot of time searching again the dir instead of asking if it's same dir 
	
        read selection2

        if [[ -z "$selection2" ]]
	then
            echo "ERROR:wrong insertion type,insert an integer"
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
                find . -type d -name "*${folder}*" > dnglab.txt
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

			
     			#repeat conversion process to convert all files in a folder
                        # for file in "$selection"/*
			# do
                        #     if [[ "$f1_1" == "1" ]]
			#     then
                        #         dnglab convert -c lossless --dng-preview true --dng-thumbnail true --embed-raw true "$file" "${file%.*}.DNG" 
			#     else
			# 	#with preview and thumbnails:	dnglab convert -c lossless --dng-preview true --dng-thumbnail true "$file" "${file}.DNG"
			#     coproc dnglab convert -c lossless --dng-thumbnail true --dng-preview false --embed-raw false  "$file" "${file%.*}.DNG"
			#     fi
                        # done

			#versione modificata per processing parallelo
			maxnproc=$(nproc)
			for file in "$selection"/*				    	    
			do
			    while (( $(jobs -r | wc -l) >= maxnproc ))  # the process number must be less or equal to the nproc number(cpu core count. + hyperthreading)
			    do
				sleep 0.06   #time needed to check
			    done
			    
                            if [[ "$f1_1" == "1" ]]
			    then
                                dnglab convert -c lossless --dng-preview true --dng-thumbnail true --embed-raw true "$file" "${file%.*}.DNG" &
			    else
				#with preview and thumbnails:	dnglab convert -c lossless --dng-preview true --dng-thumbnail true "$file" "${file}.DNG"
				dnglab convert -c lossless --dng-thumbnail true --dng-preview false --embed-raw false  "$file" "${file%.*}.DNG" &
			    fi

                        done

			wait #wait the process
                        shopt -u nullglob

                        echo "Process completed"
                        exit 0
                    fi
                fi	
                ;;

	    
            
            2|2.|file|name)
                echo "Enter file name:"
                read f2
                echo "Converting..."
		#default: embed image preview and thumbnail data into the file,it can be displayed on all image viewers(if dng's support is available)
                dnglab convert -c lossless --dng-preview true --dng-thumbnail true "$f2" "$f2.DNG" || { echo "ERROR: conversion not completed"; exit 1; }

                echo "Conversion process completed"
		#maybe in next verions find . -type f -iname "*.DNG"
                exit 0
                ;;

            *)
                echo "ERROR: not found"
                exit 1
	esac
        ;;
    

    3|3.|Exit)
        echo "Exit"
        exit 0
        ;;

    *)
        echo "ERROR: not found"
        exit 1
        ;;
esac

