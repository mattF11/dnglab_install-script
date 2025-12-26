#!/bin/bash
# AUTHOR: mattF11
# VERSION: 1.0
# DESCRIPTION: dnglab script to perform installation and basic functions
#random logo
echo "
____________________________
|	                   	   |
|      |      |        	   |
|      |      | _ |    	   |
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
echo "$USER, select the action(1/2/3) 
1. Install dnglab
2. DNG-Convertion
3. Exit

: "

read selection

# 1.1 check if string is inserted
if [[ -z "$selection" ]]
then  # string insertion,insert a number instead of a string
    echo -n "ERROR:wrong insertion type,insert an interger"
else
    echo -n "Insertion type: CORRECT"
fi

#################################################################################
# 1.1.0/1.2.0 available options: 
case $selection in
    
    1|1.|Install|dnglab)
        echo "Selected: Install dnglab"           
        # 1.1.1 process installation:dnglab
        # not-case-sensitive directory search
        cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }
        # verify if directory already exists,if that's the case,exit the program
        if [[ -d "$b" ]]
	then
            echo "Abort installation..dnglab already installed"
            exit 0
        else
            echo "Starting installation process.."
        #look at the official github page if you want to know more about the project.  
            git clone https://github.com/dnglab/dnglab.git || { echo "ERROR: git clone failed"; exit 1; 
            cd "$b" || { echo "ERROR: cannot cd into $b"; exit 1; }
          #|| { echo "ERROR: cannot cd into $b"; exit 1; } for the other condition
            cargo build --release || { echo "ERROR: cargo build failed"; exit 1; }
    
            # next we add dnglab to path
            echo "Do you want to add dnglab to system PATH?(Y/N):"
            read select

            if [[ "$select" == "Y" ]]
	    then
                echo "Y:selected,adding dnglab to PATH"
                cd "$c" || { echo "ERROR: cannot cd into $c"; exit 1; }
                export PATH="$PATH:$(pwd)"
                echo "Action completed,dnglab added to PATH for this session"
                exit 0
            else
                echo "N:selected,actions finished"
                exit 1
            fi
        fi
        ;;

########################################################################################
# 2.0 selection n2
    2|2.|DNG|dng)
        echo "Selected: DNG-Convertion"
        echo "Select(1/2):
    1. Insert folder name
    2. Insert file name
    : "
    
        read selection2

        # check if string is inserted
        if [[ -z "$selection2" ]]
	then  # string insertion,insert a number instead of a string
            echo "ERROR:wrong insertion type,insert an interger"
            exit 1
        else
            echo "Insertion type: CORRECT" #correct type of insertion
        fi
                   
        case $selection2 in
            1|1.)
                # return to the home directory
                cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }
                echo "Search folder/directory:"
                read folder
                # Find directory: not case sensitive and copy result to dnglab.txt
                find . -type d -iname "*$folder*" > dnglab.txt
                i=0
		
                # read file content(results of search)
                while read line
                do  
                    echo "[$i] $line"
                    # association between result and line 
                    ris[$i]="$line"
                    ((i++))    
                done < dnglab.txt # read file dnglab.txt
        
                # counter =0 --> not found
                if [[ "$i" -eq "0" ]]
		then
                    echo "Directory not found"
                    exit 1
                else
                    echo "Directory found"
                    echo "Select a directory/folder(n):"
                    read dir
                    selection=${ris[$dir]}
                    echo "$dir:selected"
                    echo "Do you want to convert the entire directory/folder? (1=yes/2=no)"
                    read f1


		    
                    if [[ "$f1" != "1" ]]
		    then # verify selection
			
                        echo "no:action cancelled"
                        exit 0
			
                    else
                        echo "yes:directory/folder convertion selected"
                        echo "Do you want to copy original RAW into DNG file? (1=yes/2=no)"
                        read f1_1
                        # dnglab command
                        dnglab1="dnglab convert \"$f1_1\" \"${f1_1}.DNG\""

                        eval "$dnglab1"
                        echo "Directory converted"
                        exit 0
                    fi
                fi
                ;;
        
            2|2.|file|name)  # selection 2
                echo "Enter file name:"
                read f2

                echo "Converting.."
                # dnglab command
                dnglab convert "$f2" "$f2.DNG" || { echo "ERROR:convertion not completed"; exit 1; }
              
                echo "Conversion process completed"
                find . -type f -iname "*.DNG"
                exit 0
                ;;

            *)
                echo "ERROR:not found"
                exit 1
                ;;
        esac
        ;;

    3|3.|Exit)  # selection 3
        echo -n "Exit"
        exit 0
        ;;

    *)
        # last option(not found)
        echo "ERROR:not found"
        exit 1
        ;;
esac
