#!/bin/sh
# Filename: update_script.sh
# Description: Script to automate building an adblocking hosts file

# Perform work in temporary files
adaway_hosts="/etc/adway/hosts"
last_update=$(date)

# Adway lists
adaway_list="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
             https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"

# Replace old adway hosts file
rm -vf "${adaway_hosts}"
echo "# There is no place like 127.0.0.1" >> "${adaway_hosts}"
echo "# Last update at ${last_update}" >> "${adaway_hosts}"

# Obtain various hosts files and merge into one
echo "Downloading adaway list ..."
for src in ${adaway_list}
do
   echo "Download from $src"
   wget -q --no-check-certificate -O - "$src" >> "${adaway_hosts}"
done

# Processing hosts file:
# 1. Remove MS-DOS carriage returns
# 2. Replace 127.0.0.1 with 0.0.0.0 because then we don't have to wait for the
#    resolver to fail
# 3. Delete all lines that don't begin with 0.0.0.0
# 4. Delete any lines containing the word localhost because we'll obtain that
#    from the original hosts file
# 5. Delete any comments on lines
# 5. Convert tabs to spaces
# 6. Remove extra spaces
# 7. Remove sentry.io, ipinfo.io and fonts.googleapis.com (googleadapis.l.google.com)
echo "Parsing and merging hosts files..."
sed -i -e 's/\r//' -e 's/127.0.0.1/0.0.0.0/' -e '/^0.0.0.0/!d' \
    -e '/localhost/d' -e 's/#.*$//' -e 's/\t/ /g' -e 's/  */ /g' \
    -e '/sentry.io/d' -e '/ipinfo.io/d' -e '/googleadapis.l.google.com/d' \
    "${adaway_hosts}"

# delete duplicate, consecutive lines from a file (emulates "uniq").
# First line in a set of duplicate lines is kept, rest are deleted.
sed -i '$!N; /^\(.*\)\n\1$/!P; D' "${adaway_hosts}"
