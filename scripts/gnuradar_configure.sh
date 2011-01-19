#!/bin/bash

./bootstrap
./configure --enable-usrp --enable-gruel --enable-docs --disable-all-components
make
make install
