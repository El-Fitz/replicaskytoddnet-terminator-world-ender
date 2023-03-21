#!/bin/bash

mkdir Project && cd Project && swift package init --type executable && swift package generate-xcodeproj && rm -f ./Sources/Project/Project.swift
