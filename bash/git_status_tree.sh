#!/usr/bin/env bash

git status --porcelain | awk '{print $2}' | tree --fromfile
