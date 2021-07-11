#Library file containing functions for creating and editing addressbook
#Since this is a library file, there's no need to call bin/bash

# Global variables
username=`whoami`
BOOK=~/.${username}-todobook
export BOOK; #Export so this BOOK variable can be used in other codes without redefining
export username

confirm()
{
  echo -en "$@"
 
 read ans
  ans=`echo $ans | tr '[a-z]' '[A-Z]'`
  if [ "$ans" == "Y" ]; then
    return 0
  else
    return 1
  fi
}

#search lines containing a word in BOOK with grep
#then count how many lines are returned by grep with word count wc
#and return this value with awk ($1 refers to the first argument)
num_lines()
{
  grep -i "$@" $BOOK|wc -l| awk '{ print $1 }'
}

find_lines()
{
  # Find lines matching $1
  res=-1
  #if the first argument is not a 0 length string, search for it using grep
  if [ ! -z "$1" ]; then
    grep -i "$@" $BOOK
    res=$?
  fi
  return $res
}

list_items()
{
  # List items matching given search criteria
  #if the number of arguments passed is zero, then user hasn't written an input
  if [ "$#" -eq "0" ]; then
    echo -en "Search for: (return to list all) "
    read search
    if [ -z "$search" ]; then
      search="."
    fi
    echo
  else
    search="$@"
  fi
  echo -e "DateAdded\tDateDue\tDifficultyLvl\tTopic\tDescription"
  find_lines "${search}" | while read i
  do
    echo "$i" | tr ':' '\t'
  done
  echo -en "Matches found: "
  num_lines "$search"
}

add_item()
{
  echo "Add Item: You will be prompted for 4 items:"
  echo "Remember add small tasks so you can distribute your work better!"
  echo "  - Topic, Description, Difficulty Level, Due Date.(We also automatically record the date you added an item.)"
  echo
  echo -en "Topic: "
  read topic
  echo -en "Description: "
  read description
  find_lines "^${description}:"
  if [ `num_lines "^${description}:"` -ne "0" ]; then
     echo "Sorry, $description already has an entry."
     return
  fi
  echo -en "Difficulty Level[1-10]: "
  read diffLvl
  if ! [[ "$diffLvl" =~ ^[0-9]+$ ]]; then
     echo "That doesn't look like a number hmmm..."
     return
  fi
  echo -en "Due Date [use format dd-mm-yy]: "
  read due_date
  #Check for formatting
  is_valid=`date +"%d-%m-%y" -d "${due_date}" > /dev/null 2>&1`
  if [ ! $? ]; then
     echo "That ain't quite the format mate, 'member dd-mm-yy"
     return
  fi
  start_date=`date +"%d-%m-%y"`
  # Confirm
  echo "${start_date}:${due_date}:${diffLvl}:${topic}:\"${description}\"" >> $BOOK
}

locate_single_item()
{
  echo -en "Item to search for: "
  read search
  n=`num_lines "$search"`
  if [ -z "$n" ]; then
    n=0
  fi
  #only when there is one item found we know specifically the item
  while [ "${n}" -ne "1" ]; do
    #list_items "$search"
    echo -en "${n} matches found. Please choose a "
    case "$n" in 
      "0") echo "less" ;;
      "*") echo "more" ;;
    esac
    echo "specific search term (q to return to menu): "
    read search
    if [ "$search" == "q" ]; then
      return 0
    fi
    n=`num_lines "$search"`
  done
  return `grep -in $search $BOOK |cut -d":" -f1`
}

remove_item()
{
  locate_single_item
  search=`head -$? $BOOK | tail -1|tr ' ' '.'`
  if [ -z "${search}" ]; then
	return
  fi
  list_items "$search"
  confirm "Remove?"
  if [ "$?" -eq "0" ]; then
    grep -v "$search" $BOOK > ${BOOK}.tmp ; mv ${BOOK}.tmp ${BOOK}
  else
    echo "NOT REMOVING"
  fi
}

edit_item()
{
  locate_single_item
  search=`head -$? $BOOK | tail -1|tr ' ' '.'`
  if [ -z "${search}" ]; then
	return
  fi
  list_items "$search"
  thisline=`grep -i "$search" $BOOK`
  oldstartdate=`echo $thisline|cut -d":" -f1`
  oldduedate=`echo $thisline|cut -d":" -f2`
  olddiffLvl=`echo $thisline|cut -d":" -f3`
  oldtopic=`echo $thisline|cut -d":" -f4`
  olddescription=`echo $thisline|cut -d":" -f5|sed -r 's/[\"]+//g'`
  echo "SEARCH : $search"
  grep -v "$search" $BOOK > ${BOOK}.tmp ; mv ${BOOK}.tmp ${BOOK}
  echo -en "Topic [ $oldtopic ] "
  read topic
  if [ -z "$topic" ]; then
    topic=$oldtopic
  fi
  echo -en "Description [ $olddescription ] "
  read description
  if [ -z "$description" ]; then
    description=$olddescription
  fi
   find_lines "^${description}:"
  if [ `num_lines "^${description}:"` -ne "0" ]; then
    echo "Sorry, $description already has an entry."
    return
  fi
  echo -en "Difficulty Level [$olddiffLvl] "
  read diffLvl
  if [ -z "$diffLvl" ];then
     diffLvl=$olddiffLvl
  fi
  if ! [[ "$diffLvl" =~ ^[0-9]+$ ]]; then
     echo "That doesn't look like a number hmmm..."
     return
  fi
  echo -en "Due Date [ $oldduedate ] "
  read due_date
  if [ -z "${due_date}" ]; then
    due_date=$oldduedate
  fi
  #Check for formatting
  is_valid=`date +"%d-%m-%y" -d ${due_date} > /dev/null 2>&1`
  if [ ! $? ]; then
     echo "That ain't quite the format mate, 'member dd-mm-yy"
     return
  fi
  echo "${oldstartdate}:${due_date}:${diffLvl}:${topic}:\"${description}\"" >> $BOOK
}

#Sort by due date
sort_due_date(){
  echo "Sorted by due date!"
  echo -e "DateAdded\tDateDue\tDifficultyLvl\tTopic\tDescription"
  cat $BOOK |tr ":" " "|tr "-" " "|sort -k6n -k5n -k4n
}

sort_diffLvl(){
  echo "Sorted by difficulty!"
  echo -e "DateAdded\tDateDue\tDifficultyLvl\tTopic\tDescription"
  cat $BOOK |tr ":" " "|tr "-" " "|sort -k7
}
#cat ~/.gorzy-todobook |tr ":" " "|tr "-" " "|sort -k6 -k5 -k4
#Sort by diff lvl
#cat ~/.gorzy-todobook |tr ":" " "|tr "-" " "|sort -k7