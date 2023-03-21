#!/bin/bash


echo "import Foundation


struct File: Codable {
    let filename: String
    let content: String
}


typealias FileList = [File]


func createFiles(outputPath: String, from jsonString: String) {
    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: outputPath) {
        do {
            try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(\"Error: Could not create output directory.\")
            return
        }
    }

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
            let fileURL = URL(fileURLWithPath: outputPath).appendingPathComponent(file.filename)
            try file.content.write(to: fileURL, atomically: true, encoding: .utf8);
            print(\"Created file: \(file.filename)\");
        } catch {
            print(\"Error: Could not create file \(file.filename)\");
        }
    }
}


if CommandLine.arguments.count != 3 {
    print(\"Usage: ./Project outputDirectoryPath pathToFile\")
    exit(1)
}


let outputPath = CommandLine.arguments[1]
let pathToFile = CommandLine.arguments[2]
if let jsonString = try? String(contentsOfFile: pathToFile) {
    createFiles(outputPath: outputPath, from: jsonString)
} else {
    print(\"Error: Could not read JSON file at path '\(pathToFile)'\")
}
" > ./Project/Sources/Project/main.swift
