#!/bin/sh
rm -f lib/extend/*js
rm -f lib/*js
coffee --transpile -o lib/extend -c lib/extend/*.coffee
coffee --transpile -o lib -c lib/*.coffee