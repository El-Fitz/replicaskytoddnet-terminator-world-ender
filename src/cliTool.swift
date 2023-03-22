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

var caughtErrors: [String] = []

func createDirectory(at directoryPath: String, directoryInfo: DirectoryInfo) {
  let directoryURL = URL(fileURLWithPath: directoryPath)
  do {
    try FileManager.default.createDirectory(at: directoryURL.appendingPathComponent(directoryInfo.path), withIntermediateDirectories: true, attributes: nil)
    print("Created directory: \(directoryInfo.path)")
  } catch {
    let errorMsg = "Error creating directory: \(directoryInfo.path) - \(error)"
    print(errorMsg)
    caughtErrors.append(errorMsg)
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
    caughtErrors.append(errorMsg)
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
    if let error, error.count > 0 {
      caughtErrors.append(error)
    }
    print("Script '\(scriptInfo.name)' output:\n\(output ?? ""), error:\n\(error ?? "")")
  } catch {
    let errorMsg = "Error running script: \(scriptInfo.name) - \(error)"
    print(errorMsg)
    caughtErrors.append(errorMsg)
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

func sendErrorsToBackend() {
  print("Sending errors to backend")
  let url = URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")

  let errorInfo = ErrorInfo(errors: caughtErrors)
  do {
    request.httpBody = try JSONEncoder().encode(errorInfo)
  } catch {
    print("Error encoding errors: \(error)")
  }

  print("Will send errors to backend")
  let group = DispatchGroup()
  group.enter()
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
      print("Error sending errors to backend: \(error)")
      return
    }
    print("Errors sent to backend successfully")
    group.leave()
  }
  print("Resuming task")
  task.resume()
  group.wait()
  print("Resumed")
}

func writeErrors() {
  guard !caughtErrors.isEmpty else { return }
  let errorInfo = ErrorInfo(errors: caughtErrors)
  let errorFileURL = URL(fileURLWithPath: "./errors.json")
  do {
    let errorData = try JSONEncoder().encode(errorInfo)
    try errorData.write(to: errorFileURL, options: .atomicWrite)
    sendErrorsToBackend()
  } catch {
    print("Error writing errors.json: \(error)")
  }
}

func main() {
  defer { writeErrors() }

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
    let errorMsg = "Error processing JSON file: \(error)"
    print(errorMsg)
    caughtErrors.append(errorMsg)
  }
}

main()