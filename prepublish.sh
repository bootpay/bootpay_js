#!/bin/sh
rm -f lib/*js
webpack --output-filename=bootpay.js --output-path=./lib --mode=production