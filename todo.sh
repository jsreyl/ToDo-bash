#!/bin/bash
# To Do List

#When we get a 2 (i.e. an error), execute do_menu again
trap 'do_menu' 2

#include the library where we have defined the funtions to add edit remove items
. /home/gorzy/Documents/User_Bash_utilities/todo_libs.job

show_menu()
{
  # Called by do_menu
  
  echo
  echo
  echo
  echo
  echo "-- ${username}'s To Do List :D --"
  echo "1. List / Search"
  echo "2. Add"
  echo "3. Edit"
  echo "4. Remove"
  echo "5. Display by Due Date"
  echo "6. Display by difficulty"
  echo "q. Quit"
  echo -en "Enter your selection: "
}

do_menu()
{
  i=-1

  while [ "$i" != "q" ]; do
    show_menu
    read i
    i=`echo $i | tr '[A-Z]' '[a-z]'`
    case "$i" in 
    	"1")
      	list_items
        ;;
      "2")
        add_item
        ;;
      "3")
      	edit_item
        ;;
      "4")
      	remove_item
        ;;
      "5")
        sort_due_date
        ;;
      "6")
        sort_diffLvl
        ;;
      "q")
        confirm "Really quit?(y/n)"
        echo "Goodbye ${username}.Have a productive day!"
        exit 0
        ;;
      *)
      	echo "Didn't quite get that. Try again? [Unrecognized input]"
        ;;
    esac
    continue=-1
    while [ ! -z "$continue" ]; do
          echo -en "Press RETURN to continue: "
          read continue
    done
  done
}

##########################################################
############ Main script starts here #####################
##########################################################

#If there's no book then create one at ~/.addressbook
if [ ! -f $BOOK ]; then
  echo "Creating $BOOK ..."
  touch $BOOK
fi

if [ ! -r $BOOK ]; then
  echo "Error: $BOOK not readable"
  exit 1
fi

if [ ! -w $BOOK ]; then
  echo "Error: $BOOK not writeable"
  exit 2
fi

do_menu
