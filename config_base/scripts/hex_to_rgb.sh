#!/bin/bash
hex=$1

# Strip possible leading '#'
hex="${hex#"#"}"

r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))

echo "$r,$g,$b"
