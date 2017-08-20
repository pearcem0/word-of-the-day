#!/bin/bash

wordoftheday=`curl -s -L "www.dictionary.com/wordoftheday" | grep "Definitions for <strong>daymare</strong>" | sed 's/Definitions for <strong>//g' | sed 's/<\/strong>//g' | tr -d ' '`

printf "Today's Word of the Day is... $wordoftheday!\n\n"

# Get a page to work with and manipulate
curl -sL "www.dictionary.com/wordoftheday" > wotd.page

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
  echo $line | awk -F"<span>" '{print $2}' | awk -F"</span>" '{print $1}'
done

printf "\nTo read more you can go to https://www.dictionary.com/browse/$wordoftheday\n\n"

rm wotd.page*
