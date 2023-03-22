import Foundation

struct FileInfo: Codable {
  let filename: String
  let content: String
}

struct ScriptInfo: Codable {
  let name: String
  let script: String
}

enum Item: Codable {
  case file(filename: String, content: String)
  case script(name: String, script: String)
}

func createFile(at directoryPath: String, fileInfo: FileInfo) {
  let fileURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileInfo.filename)
  do {
    try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    try fileInfo.content.write(to: fileURL, atomically: true, encoding: .utf8)
    print("Created file: \(fileInfo.filename)")
  } catch {
    print("Error creating file: \(fileInfo.filename) - \(error)")
  }
}

func runScript(from directoryPath: String, scriptInfo: ScriptInfo) {
  let task = Process()
  task.currentDirectoryPath = directoryPath
  task.launchPath = "/bin/bash"
  task.arguments = ["-c", scriptInfo.script]

  let outputPipe = Pipe()
  task.standardOutput = outputPipe

  do {
    try task.run()
    task.waitUntilExit()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8)
    print("Script '\(scriptInfo.name)' output:\n\(output ?? "")")
  } catch {
    print("Error running script: \(scriptInfo.name) - \(error)")
  }
}

func processItems(at directoryPath: String, items: [Item]) {
  for item in items {
    switch item {
    case let .file(filename, content):
      createFile(at: directoryPath, fileInfo: .init(filename: filename, content: content))
    case let .script(name, script):
      runScript(from: directoryPath, scriptInfo: .init(name: name, script: script))
    }
  }
}

func main() {
  guard CommandLine.arguments.count == 3 else {
    print("Usage: ./cliTool <output-directory> <path-to-json>")
    return
  }

  let outputDirectory = CommandLine.arguments[1]
  let jsonPath = CommandLine.arguments[2]

  do {
    let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
    let items = try JSONDecoder().decode([Item].self, from: jsonData)
    processItems(at: outputDirectory, items: items)
  } catch {
    print("Error processing JSON file: \(error)")
  }
}

main()