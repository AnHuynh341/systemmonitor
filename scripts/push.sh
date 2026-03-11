#!/bin/bash

cd /home/AnHuynh/sys-mon/ || exit

git add logs/ 

if ! git diff --cached --quiet; then
    git commit -m "Daily monitor update $(date '+%Y-%m-%d')"
    git push
fi
