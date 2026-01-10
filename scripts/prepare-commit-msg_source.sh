#!/bin/sh
#

TASK_PREFIX="PROD-"
BRANCH=`git symbolic-ref -q HEAD | sed s:refs/heads/::`
MESSAGE=`cat "$1"`

if [[ $BRANCH == *"$TASK_PREFIX"* ]]; then
    TASK_NAME="$(echo "$BRANCH" | sed -E "s/.*\/(${TASK_PREFIX}[0-9]+).*/\1/")"
    if [[ MESSAGE == $TASK_NAME* ]] || [[ MESSAGE == Merge* ]] || [[ -z "$TASK_NAME" ]]
    then
        echo "$MESSAGE" > "$1"
    else
        echo "$TASK_NAME: $MESSAGE" > "$1"
    fi
fi
