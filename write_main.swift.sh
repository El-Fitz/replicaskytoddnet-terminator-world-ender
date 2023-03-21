#!/bin/bash


echo "import Foundation


struct File: Codable {
    let filename: String
    let content: String
}


typealias FileList = [File]


func createFiles(from jsonString: String) {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print(\"Error: Invalid JSON string.\")
        return;
    }
    let decoder = JSONDecoder();
    let fileList: FileList;


    do {
        fileList = try decoder.decode(FileList.self, from: jsonData);
    } catch {
        print(\"Error: Invalid JSON string.\")
        return;
    }


    for file in fileList {
        do {
            try file.content.write(toFile: file.filename, atomically: true, encoding: .utf8);
            print(\"Created file: \(file.filename)\");
        } catch {
            print(\"Error: Could not create file \(file.filename)\");
        }
    }
}


if CommandLine.arguments.count != 2 {
    print(\"Usage: ./Project pathToFile\")
    exit(1)
}


let pathToFile = CommandLine.arguments[1]
if let jsonString = try? String(contentsOfFile: pathToFile) {
    createFiles(from: jsonString)
} else {
    print(\"Error: Could not read JSON file at path '\(pathToFile)'\")
}
" > ./Project/Sources/Project/main.swift
