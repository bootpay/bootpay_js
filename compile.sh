#!/bin/sh
node_modules/.bin/webpack --output-filename=bootpay-$1.min.js --output-path=./dist --mode=production
gzip -c dist/bootpay-$1.min.js > dist/bootpay-$1.min.js.gz