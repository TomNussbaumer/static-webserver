#!/bin/bash

#params infomessage
showInfo() {
  echo "[INFO] $1"
}

#params errormessage
showError() {
  echo "[ERROR] $1"
  #exit $2
}

#params message exitcode
showResult() {
  if [ $2 -eq 0 ]; then
    echo "[PASS] $1"
  else
    echo "[FAIL] $1"
  fi
}

OPTIONAL_OUTPUT="";
if [ $# -gt 0 ] && [ "$1" != "" ]; then
  OPTIONAL_OUTPUT=" [$1]"
fi

doExit() {
  showInfo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  showResult "$1$OPTIONAL_OUTPUT" $2
  showInfo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  showInfo "exitcode=$2"
  tmppid=$(jobs -rp)
  [ "$tmppid" != "" ] && kill $tmppid
  exit $2;
}

TESTFILE=/home/tester/test.txt
[ -f "$TESTFILE" ] && rm $TESTFILE

cd /home/tester/import/tests
../static-webserver.sh 8080 $1 &
showInfo "sleeping a while to give webserver time to start ..."
sleep 5

if [ "$(jobs -rp)" = "" ]; then
   doExit "webserver not running" 4
fi


curl -sS --fail localhost:8080 > $TESTFILE

if [ $? -ne 0 ]; then
   doExit "fetching index.html with curl failed" 1
fi

if [ -f $TESTFILE ]; then
  diff -q index.html $TESTFILE 1>/dev/null
  if [ $? -eq 0 ]; then
     doExit "fetched /index.html and compared it" 0
  fi 
  
  doExit "diff index.html with curl result failed" 2
fi

doExit "cannot find retrieved file" 3
