#!/usr/bin/env bash

for task in $(find tools/ -maxdepth 1 -type f); do
    bash -c "${task}"
done
