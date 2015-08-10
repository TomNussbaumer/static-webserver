#!/bin/sh

# script to run tests against static-webserver.sh
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Tom Nussbaumer <thomas.nussbaumer@gmx.net
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

## test for preserving spaces
# VAR1="a b c"; IFS=''; for a in $VAR1; do echo $a; done; unset IFS

LOGFILE=tests.log
[ -f "$LOGFILE" ] && rm $LOGFILE

#params infomessage
showInfo() {
  echo "[INFO] $1" | tee -a $LOGFILE
}

#params errormessage
showErrorNoExit() {
  echo "[ERROR] $1" | tee -a $LOGFILE
}

#params errormessage exitcode
showError() {
  showErrorNoExit $1
  exit $2
}

if [ "$(which docker)" = "" ]; then
  showErrorNoExit "docker is not installed or cannot be found"
  showInfo ""
  showInfo "Please install docker to run the tests."
  showInfo ""
  showInfo "see: https://docs.docker.com/installation/"
  exit 1
fi  

if [ "$(docker info)" -ne 0 ]; then
  showErrorNoExit "ERROR: docker not working properly"
  showInfo ""
  showInfo "check: sudo service docker status"
  showInfo "start: sudo service docker start"
  showInfo ""
  exit 1
fi

TMPVAR=$(dirname "$(pwd)/$0")
ABSPATH_HOME=$(readlink -f "$TMPVAR/..")

TESTIMAGE=static-webserver-test:latest
TESTCONTAINER=static-webserver-testcontainer

if [ "$(docker images -q $TESTIMAGE)" = "" ]; then
  showInfo "$TESTIMAGE not found. building it now ..."
  docker build -t $TESTIMAGE "$ABSPATH_HOME/tests"
  if [ $? -ne 0 ]; then
     showError "build failed. wtf?" 1
  fi
fi

CID=$(docker ps -aq --no-trunc --filter "name=$TESTCONTAINER");
if [ "$CID" ]; then
  showInfo "old container found. removing it"
  docker rm -f $CID
fi

TESTSCRIPT=test_variant.sh

testVariant() {
  showInfo "run $TESTSCRIPT in container with param [$1]"
  docker run -ti --rm --name=$TESTCONTAINER     \
         -v "$ABSPATH_HOME":/home/tester/import \
         $TESTIMAGE import/tests/$TESTSCRIPT $1
}

testVariant "" | tee -a $LOGFILE
testVariant "--force=python"  | tee -a $LOGFILE
testVariant "--force=python2" | tee -a $LOGFILE
testVariant "--force=python3" | tee -a $LOGFILE
testVariant "--force=php" | tee -a $LOGFILE

testPackagesRemoved() {
  CMDLINE="$1 && import/tests/$TESTSCRIPT"

  # running it with user root so we can anything we want
  showInfo "run $TESTSCRIPT in container with CMD:"
  showInfo "[$CMDLINE]"
  docker run -ti --rm --name=$TESTCONTAINER     \
         -v "$ABSPATH_HOME":/home/tester/import \
         -u root \
         $TESTIMAGE bash -c "$CMDLINE"
}

###############################################################################
# NOTE: 
#
# there is no way to uninstall python2 from ubuntu (wtf?)
# 
# For this reason and for speedup i will just delete the links and executables 
# from the container. Since it is nevertheless a throw-away container this
# doesn't matter.
# 
# DON'T do this ever on a REAL machine! Use 'apt-get remove' or whatever ... 
###############################################################################

testPackagesRemoved 'rm $(which python) $(which python2)' | tee -a $LOGFILE
testPackagesRemoved 'rm $(which python) $(which python2) $(which python3)' | tee -a $LOGFILE
# this last one is EXPECTED TO FAIL
testPackagesRemoved 'rm $(which python) $(which python2) $(which python3) $(which php)' | tee -a $LOGFILE

