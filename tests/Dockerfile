###################################################################
# image to run tests for static webserver script 
###################################################################

FROM ubuntu:14.04
MAINTAINER Tom Nussbaumer <thomas.nussbaumer@gmx.net>

#------------------------------------------------------------------
# install every software package the script supports
# + necessary stuff for testing (like curl)
#------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
        curl \
        devscripts \
        php5 \
        python \
        python3 \
        ruby

#------------------------------------------------------------------
# setup a none privileged user account to run the tests
#------------------------------------------------------------------
RUN groupadd -r tester && \
    useradd -r -g tester tester && \
    mkdir /home/tester && \
    chown tester:tester /home/tester
USER tester
WORKDIR /home/tester
