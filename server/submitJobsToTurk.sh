#!/bin/bash

RESULT="`wget -qO- http://localhost:8080/task/submitOverDue 2>&1`"
echo $RESULT >> /tmp/turkSubmitLog.log