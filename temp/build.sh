#!/bin/bash

rm -rf ./Project/ &&
./create_project.sh && 
./navigate_and_create_files.sh &&
./write_main.swift.sh &&
./build_and_run.sh
