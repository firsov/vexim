#!/bin/bash

ver=`grep "#  Installer" ../install.sh  | awk '{print $4" "$3}'`
read -p"введите описание последних изменений ~ >" comment
cp CHANGELOG CHANGELOG.old
printf "\n%10.40s - build %10.20s\n-\n%s\n--\n" "`date`" "\"$ver\""  "$comment" > CHANGELOG
cat CHANGELOG.old >> CHANGELOG
rm -f CHANGELOG.old
