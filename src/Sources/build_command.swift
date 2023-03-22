import Foundation

struct DirectoryInfo: Codable {
  let path: String
}

struct FileInfo: Codable {
  let filename: String
  let content: String
}

struct ScriptInfo: Codable {
  let name: String
  let script: String
}

struct ErrorInfo: Codable {
  let errors: [String]
}

enum Item: Codable {
  case directory(path: String)
  case file(filename: String, content: String)
  case script(name: String, script: String)
}

extension Build {
  func createOutputDirectory(_ path: String) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
  }

  func readAndParseJSONFile(_ path: String) throws -> [[String: Any]] {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
    return json
  }

  
  func createDirectory(at directoryPath: String, directoryInfo: DirectoryInfo) {
    let directoryURL = URL(fileURLWithPath: directoryPath)
    do {
      try FileManager.default.createDirectory(at: directoryURL.appendingPathComponent(directoryInfo.path), withIntermediateDirectories: true, attributes: nil)
      print("Created directory: \(directoryInfo.path)")
    } catch {
      let errorMsg = "Error creating directory: \(directoryInfo.path) - \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }

  func createFile(at directoryPath: String, fileInfo: FileInfo) {
    let fileURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileInfo.filename)
    do {
      try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
      try fileInfo.content.write(to: fileURL, atomically: true, encoding: .utf8)
      print("Created file: \(fileInfo.filename)")
    } catch {
      let errorMsg = "Error creating file: \(fileInfo.filename) - \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }

  func runScript(from directoryPath: String, scriptInfo: ScriptInfo) {
    let task = Process()
    task.currentDirectoryPath = directoryPath
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", scriptInfo.script]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = errorPipe

    do {
      try task.run()
      task.waitUntilExit()

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: outputData, encoding: .utf8)
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let error = String(data: errorData, encoding: .utf8)
      errorLogger.log(error)
      print("Script '\(scriptInfo.name)' output:\n\(output ?? ""), error:\n\(error ?? "")")
    } catch {
      let errorMsg = "Error running script: \(scriptInfo.name) - \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }

  func processItems(at directoryPath: String, items: [Item]) {
    for item in items {
      switch item {
      case let .directory(path):
        createDirectory(at: directoryPath, directoryInfo: .init(path: path))
      case let .file(filename, content):
        createFile(at: directoryPath, fileInfo: .init(filename: filename, content: content))
      case let .script(name, script):
        runScript(from: directoryPath, scriptInfo: .init(name: name, script: script))
      }
    }
  }

  func run() throws {
    defer { errorLogger.outputLogs() }

    let outputDir = outputDirectory ?? "./"

    do {
      let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonFilePath))
      let items = try JSONDecoder().decode([Item].self, from: jsonData)
      processItems(at: outputDir, items: items)
    } catch {
      let errorMsg = "Error processing JSON file: \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }
}