#!/bin/bash

. delete-project.sh
if [ $? -ne 0 ]; then return 1; fi

. delete-cluster.sh
if [ $? -ne 0 ]; then return 1; fi
