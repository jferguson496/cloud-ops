#!/bin/bash
ps -ef | grep 'actions.runner*' |grep -v grep > /dev/null
if [ $? != 0 ]
then
       sudo systemctl start 'actions.runner*' -all > /dev/null 
fi