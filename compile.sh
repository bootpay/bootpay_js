#!/bin/sh
if [ -z "$1" ]; then
    echo "버전을 입력해주세요.";
    exit;
fi
if [ -z "$2" ]; then
    MODE=development
else
    MODE=$2
fi
node_modules/.bin/webpack --output-filename=bootpay-$1.min.js --output-path=./dist --mode=$MODE
gzip -c dist/bootpay-$1.min.js > dist/bootpay-$1.min.js.gz