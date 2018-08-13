#!/bin/bash -eu

cd `dirname $0`

WAT2WASM=/usr/local/bin/wat2wasm

for file in `ls *.wat`; do
	$WAT2WASM $file -o ${file%.wat}.wasm
done
