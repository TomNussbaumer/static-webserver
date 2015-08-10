#!/bin/sh
#
# helperscript to start a static webserver on given port
# (script errorcodes start with 101 upwards)
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Tom Nussbaumer <thomas.nussbaumer@gmx.net>
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

#params infomessage
showInfo() {
  echo "[INFO] $1"
}

# params: errormessage exitcode
showUsage() {
  echo "ERROR: $1"
  echo "USAGE: $0 portnumber [--force=python|python2|python3|php]"
  echo ""
  echo "starts a static webserver to serve files from current working directory"
  echo "(Python v2, Python v3 or PHP required)"
  exit $2
}

# params: executable portnumber
startWithPHP() {
  showInfo "using php"
  showInfo "starting [$1 -S 127.0.0.1:$2]"
  "$1" -S "127.0.0.1:$2"
  exit $?
}

# params: executable portnumber
startWithPython2() {
  showInfo "using python2"
  showInfo "starting [$1 -m SimpleHTTPServer $2]"
  "$1" -m SimpleHTTPServer $2
  exit $?
}

# params: executable portnumber
startWithPython3() {
  showInfo "using python3"
  showInfo "starting [$1 -m http.server $2]"
  "$1" -m http.server $2
  exit $?
}

# params: variable
isInvalidPortNumber() {
  tmp=$(echo "$1" | grep -E '^[0-9]+$')
  [ "$tmp" = "" ] || [ $tmp -lt 1 ] || [ $tmp -gt 65535 ]
  return $?
}

if [ $# -eq 0 ]; then
  showUsage "missing parameter portnumber" 101
elif isInvalidPortNumber $1; then
  showUsage "invalid portnumber $1" 102
fi

FORCE=""

if [ $# -gt 1 ]; then
  PARAM=$(echo $2 | cut -d= -f1);
  if [ "$PARAM" != --force ]; then
    showUsage "unknown parameter $2" 103
  fi

  FORCE=$(echo $2 | cut -d= -f2);

  case "$FORCE" in
    "python")  showInfo  "forcing generic python";;
    "python2") showInfo  "forcing python2";;
    "python3") showInfo  "forcing python3";;
    "php")     showInfo  "forcing php";;
    *)         showUsage "unknown force directive [$FORCE]" 104;;
  esac
fi

PYTHON="$(which python)";
PYTHON_VERSION="";
if [ "PYTHON" != "" ]; then
   PYTHON_VERSION=$(python --version 2>&1 | cut -d. -f1)
fi

PYTHON2="$(which python2)";
PYTHON3="$(which python3)";
PHP="$(which php)";


if [ "$FORCE" = "" ] || [ "$FORCE" = "python" ]; then
  if [ "$PYTHON" != "" ]; then
    if [ "$PYTHON_VERSION" = "Python 2" ]; then
      startWithPython2 python $1
    else
      startWithPython3 python $1
    fi
  elif [ "$PYTHON2" != "" ]; then
    startWithPython2 python2 $1
  elif [ "$PYTHON3" != "" ]; then
    startWithPython3 python3 $1
  else
    if [ "$FORCE" = "python" ]; then
      showUsage "neither python, python2 nor python3 found" 105
    fi

    if [ "$PHP" != "" ]; then
      startWithPHP php $1
    fi

    showUsage "none of the supported http servers found" 106
  fi
fi

if [ "$FORCE" = "python2" ]; then
  if [ "$PYTHON2" != "" ]; then
    startWithPython2 python2 $1
  elif [ "$PYTHON" != "" ] && [ "$PYTHON_VERSION" = "Python 2" ]; then
    startWithPython2 python $1
  else
    showUsage "no python 2.x installation found" 107
  fi
elif [ "$FORCE" = "python3" ]; then
  if [ "$PYTHON3" != "" ]; then
    startWithPython3 python3 $1
  elif [ "$PYTHON" != "" ] && [ "$PYTHON_VERSION" = "Python 3" ]; then
    startWithPython3 python $1
  else
    showUsage "no python 3.x installation found" 108
  fi 
elif [ "$FORCE" = "php" ]; then
  if [ "$PHP" != "" ]; then
    startWithPHP php $1
  else
    showUsage "no php installation found" 109
  fi 
fi


# if we'll come here, something really wrong happended
showUsage "THIS should not happen" 110
