#!/bin/sh

# Converts an ipv4 address to its 6to4 address
# x.veiga@udc.es, 2018-10-10

if [ $# -ne 1 ]; then
    echo "Wrong arguments: Usage ./ip4-6to4 <ipv4 address>"
else
    printf "2002:%02x%02x:%02x%02x::1\n" $(echo $1 | tr "." " ")
fi
