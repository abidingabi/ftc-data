#!/usr/bin/env fish

cd data
rm *.json
gh run download -n data-output
