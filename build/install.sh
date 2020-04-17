#!/bin/bash

echo "+ CONTROLLER IMAGE"
(cd controller && . install.sh)
if [ $? -ne 0 ]; then return 1; fi

echo && echo

echo "+ KONG IMAGE"
(cd kong && . install.sh)
if [ $? -ne 0 ]; then return 1; fi
