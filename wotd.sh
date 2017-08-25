#!/bin/bash

while getopts ":d:" opt; do
  case $opt in
    d)
      selecteddate=$OPTARG
      wordoftheday=`curl -s -L "www.dictionary.com/wordoftheday/$selecteddate" | grep "<title>" | sed 's/<title>//g' | cut -d "-" -f 1 | sed 's: | Dictionary.com</title>::g' | tr  -d ' '`
      ;;
  esac
done

[ -z "$selecteddate" ] && selecteddate=`date +%Y/%m/%d` && wordoftheday=`curl -s -L "www.dictionary.com/wordoftheday/$selecteddate" | grep "<title>" | sed 's/<title>//g' | cut -d "-" -f 2 | sed 's: | Dictionary.com</title>::g' | tr  -d ' '`

# on the same day, and before the current days wotd has not yet been added a different format is used, so get the next field in the cut
if [ "$wordoftheday" = "GettheWordoftheDay" ]; then
  wordoftheday=`curl -s -L "www.dictionary.com/wordoftheday/$selecteddate" | grep "<title>" | sed 's/<title>//g' | cut -d "-" -f 2 | sed 's: | Dictionary.com</title>::g' | tr  -d ' '`
fi

printf "Today's Word of the Day is... $wordoftheday!\n\n"

# Get a page to work with and manipulate

curl -sL "www.dictionary.com/wordoftheday/$selecteddate/$wordoftheday" > wotd.page

# Get some stats
# linecount
linecount=`sed -n '$=' wotd.page`

# Definition starts on line - 
definitionStart=`cat -n wotd.page | grep '<ol class="definition-list'  | cut -d " " -f 4`

tail -n $(($linecount - $definitionStart)) wotd.page > wotd.page.top

definitionEnd=`cat -n wotd.page.top | grep '</ol>' | cut -d " " -f 6`

head -n $(($definitionEnd-1)) wotd.page.top > wotd.page.finalcut

cat wotd.page.finalcut | while read line
do
  echo $line | awk -F"<span>" '{print $2}' | awk -F"</span>" '{print $1}' | sed -e 's:<em>::g' -e 's:</em>::g'
done

printf "\nTo read more you can go to https://www.dictionary.com/browse/$wordoftheday\n\n"

rm wotd.page*
