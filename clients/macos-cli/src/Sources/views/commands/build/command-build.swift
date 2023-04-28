import Foundation

extension Build {
  func runScript(from directoryPath: String, scriptDefinition: ScriptDefinition) {
    let task = Process()
    task.currentDirectoryPath = directoryPath
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", scriptDefinition.script]

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
      print("Script '\(scriptDefinition.name)' output:\n\(output ?? ""), error:\n\(error ?? "")")
    } catch {
      let errorMsg = "Error running script: \(scriptDefinition.name) - \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }
  
  func runScripts(from directoryPath: String, scriptsDefinitions: [ScriptDefinition]) {
    for scriptDefinition in scriptsDefinitions {
      runScript(from: directoryPath, scriptDefinition: scriptDefinition)
    }
  }

  func retrieveProjectDefinition(path: String) throws -> ProjectDefinition {
    print("Retrieving project definition...")
    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
    let projectDefinition = try JSONDecoder().decode(ProjectDefinition.self, from: jsonData)
    print("✅ Project definition retrieved.".bold)
    return projectDefinition
  }

  func genesis(outputDir: String, projectDefinition: ProjectDefinition) throws {
    print("🏃 Running genesis scripts...")
    let genesisScriptsDefinitions = projectDefinition.scripts.beforeFilesCreation
    runScripts(from: outputDir, scriptsDefinitions: genesisScriptsDefinitions)
    print("✅ Genesis scripts finished.".bold)
  }

  func creation(outputDir: String, projectDefinition: ProjectDefinition) throws {
    print("🖨️ Creating files...")
    try FilesRepository.createFiles(from: projectDefinition.files, fileTree: projectDefinition.fileTree, in: .root(outputDirectory: outputDirectory))
    print("✅ Files created.".bold)
  }

  func finalization(outputDir: String, projectDefinition: ProjectDefinition) throws {
    print("🏃 Running finalization scripts...")
    let finalizationScriptsDefinitions = projectDefinition.scripts.beforeFilesCreation
    runScripts(from: outputDir, scriptsDefinitions: finalizationScriptsDefinitions)
    print("✅ Finalization scripts finished.".bold)
  }

  func run() async throws {
    let outputDir = outputDirectory ?? "./"
    defer { errorLogger.outputLogs(at: "\(outputDir)/errors.json") }
    let projectDefinitionPath = self.projectDefinitionPath ?? "\(FilesRepository.Directory.tool(outputDirectory: outputDir).path)/project-description.json"
    
    do {
      print("🚀 Starting build...")
      let projectDefinition = try retrieveProjectDefinition(path: projectDefinitionPath)
      try genesis(outputDir: outputDir, projectDefinition: projectDefinition)
      try creation(outputDir: outputDir, projectDefinition: projectDefinition)
      try finalization(outputDir: outputDir, projectDefinition: projectDefinition)
      print("🎉 Build finished.".bold)
    } catch {
      let errorMsg = "Error processing JSON file: \(error)"
      print(errorMsg)
      errorLogger.log(errorMsg)
    }
  }
}