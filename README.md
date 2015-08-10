# static-webserver

## Purpose

If you are running some flavour of unix on your machine it's quite likely there is already software installed which may function as simple static webserver.

This script helps to start one of them without knowing what's actually installed.

## Usage

```
USAGE: ./static-webserver.sh portnumber [--force=python|python2|python3|php]

starts a static webserver to serve files from current working directory
(Python v2, Python v3 or PHP required)
```

As stated in the usage info above actually only python and php are supported.

## Additional info

The subdirectory tests contains a first version of a test suite for this script using Docker. The suite performs the following actions:

1. build an ubuntu 14.04 based image with python2, python3 and php installed 
2. run script with all different --force options and check if a file can be fetched from static webserver
3. remove package by package (in auto-detection order) and check if it still starts a static webserver

The test suite is quite messy due to its quick and dirty nature. Nevertheless it demonstrates how testing and Docker are a perfect match.

I've have tried to avoid any bashism in static-webserver.sh and run-tests.sh. Therefore they should run with any posix-compliant shell. 
