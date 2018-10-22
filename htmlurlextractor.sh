#!/bin/sh
cat $1 | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort | unique $2
