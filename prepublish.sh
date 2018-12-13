#!/bin/sh
rm -f lib/*js
coffee --transpile -o lib -c lib/*.coffee