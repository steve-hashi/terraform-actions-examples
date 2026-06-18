#!/bin/bash

DATA=$(</dev/stdin)
echo "stdin: $DATA, args: $@"
exit $1