#!/bin/bash

./boostrap
./configure --enable-usrp --enable-gruel --enable-docs --disable-all-components
make
make install
