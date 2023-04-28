import Foundation

struct OpenaiRequirementsMessages: Codable {
  let messages: [OpenaiChatRepository.Message]

  init(systemMessage: String, userMessage: String) {
    self.messages = [
      .init(role: .system, content: systemMessage),
      .init(role: .user, content: userMessage),
    ]
  }
}

extension Generate {
  func createOutputDirectory(_ path: String) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
  }

  func generateDocument<T>(_ documentName: String, textLoaderTitle: String, completionTitle: String, generator: () async throws -> T?, saveDocument: (T) throws -> String, deleteDocument: () throws -> Void, askUserForDocumentApproval: (T) async throws -> Bool) async throws -> T {
    terminal.startTextTimerLoader(textLoaderTitle, inline: true)
    guard let document = try await generator() else {
      terminal.stopTextTimerLoader()
      throw GenerateError.failedGeneratingDocument(documentName)
    }
    terminal.stopTextTimerLoader()

    terminal.printText(completionTitle, inline: true)
    let filePath = try saveDocument(document)
    terminal.printText("💾 Saved \(documentName) at \(filePath).", inline: false)

    guard try await askUserForDocumentApproval(document) else {
      terminal.printText("🗑️ Deleting \(documentName)...", inline: true)
      try deleteDocument()
      terminal.printText("🗑️ Deleted \(documentName).", inline: false)
      return try await generateDocument(documentName, textLoaderTitle: textLoaderTitle, completionTitle: completionTitle, generator: generator, saveDocument: saveDocument, deleteDocument: deleteDocument, askUserForDocumentApproval: askUserForDocumentApproval)
    }
    return document
  }

  func askUserForSpecificationsApproval(_ specifications: String) -> Bool {
    let shouldContinue = terminal.promptForInput(withMessage: "Continue, using these specifications? - print (p) / yes (y) / no (n) - (YES)   ")?.lowercased()
    if shouldContinue == "print" || shouldContinue == "p" {
      terminal.printText(specifications)
      return askUserForSpecificationsApproval(specifications)
    }
    return shouldContinue == "yes" || shouldContinue == "y" || shouldContinue == "" || shouldContinue == nil
  }

  // Generate the projecs specifications based on the requirements
  // TODO: If specifications already exist, ask if the user wants to reuse them
  // TODO: If yes, skip specifications generation
  // TODO: If no, delete old specifications, generate new specifications and store them, along with a hash of the requirements
  func generateProjectSpecifications(for requirements: ProjectRequirements, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> ProjectSpecifications {
    return try await generateDocument(
      "project specifications",
      textLoaderTitle: "📝📄 Generating projects specifications... 📑📃",
      completionTitle: "📝📄 Generated projects specifications.",
      generator: { try await ProjectSpecificationsGenerator().createSpecs(for: requirements, using: openaiRepository) },
      saveDocument: { try FilesRepository.saveProjectSpecifications($0, in: outDir) },
      deleteDocument: { try FilesRepository.deleteProjectSpecifications(in: outDir) },
      askUserForDocumentApproval: askUserForSpecificationsApproval
    )
  }

  // func generateProjectSpecifications(for requirements: ProjectRequirements, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> ProjectSpecifications {

  //   terminal.startTextTimerLoader("📝📄 Generating projects specifications... 📑📃", inline: true)

  //   guard let specifications = try await ProjectSpecificationsGenerator().createSpecs(for: requirements, using: openaiRepository) else {
  //     terminal.stopTextTimerLoader()
  //     throw GenerateError.failedGeneratingProjectsSpecifications
  //   }
  //   terminal.stopTextTimerLoader()

  //   terminal.printText("📝📄 Generated projects specifications.", inline: true)
  //   let filePath = try FilesRepository.saveProjectSpecifications(specifications, in: outDir)
  //   terminal.printText("💾 Saved specifications at: \(filePath)", inline: false)
  
  //   guard askUserForSpecificationsApproval(specifications) else {
  //     terminal.printText("🗑️ Deleting specifications...", inline: true)
  //     try FilesRepository.deleteProjectSpecifications(in: outDir)
  //     terminal.printText("🗑️ Deleted specifications.", inline: true)
  //     return try await generateProjectSpecifications(for: requirements, using: openaiRepository, in: outDir)
  //   }
  //   return specifications
  // }

  func askUserForFileTreeApproval(_ fileTree: FileTree) throws -> Bool {
    let shouldContinue = terminal.promptForInput(withMessage: "Continue, using this file tree? - print (p) / yes (y) / no (n) - (YES)   ")?.lowercased()
    if shouldContinue == "print" || shouldContinue == "p" {
      let fileTreeString = String(data: try JSONEncoder().encode(fileTree), encoding: .utf8) ?? ""
      terminal.printText(fileTreeString)
      return try askUserForFileTreeApproval(fileTree)
    }
    return shouldContinue == "yes" || shouldContinue == "y" || shouldContinue == "" || shouldContinue == nil
  }

  func generateProjectFileTree(for specifications: ProjectSpecifications, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> FileTree {
    return try await generateDocument(
      "file tree",
      textLoaderTitle: "🌳🌲 Generating file tree... 🏕️🌴",
      completionTitle: "🌳🌲 Generated file tree.",
      generator: { try await FileTreeGenerator().createFileTree(for: specifications, using: openaiRepository) },
      saveDocument: { try FilesRepository.saveFileTree($0, in: outDir) },
      deleteDocument: { try FilesRepository.deleteFileTree(in: outDir) },
      askUserForDocumentApproval: askUserForFileTreeApproval
    )
  }

  // Generate the file tree based on the specifications
  // TODO: If file tree already exists, ask if the user wants to reuse it
  // TODO: If yes, skip file tree generation
  // TODO: If no, delete old file tree, generate new file tree and store it, along with a hash of the specifications and the requirements
  // func generateProjectFileTree(for specifications: ProjectSpecifications, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> FileTree {
  //   terminal.startTextTimerLoader("🌳🌲 Generating file tree... 🏕️🌴", inline: true)

  //   guard let fileTree = try await FileTreeGenerator().createFileTree(for: specifications, using: openaiRepository) else {
  //     terminal.stopTextTimerLoader()
  //     throw GenerateError.failedGeneratingFileTree
  //   }

  //   terminal.stopTextTimerLoader()

  //   terminal.printText("🌳🌲 Generated file tree.", inline: true)
  //   let filePath = try FilesRepository.saveFileTree(fileTree, in: outDir)
  //   terminal.printText("💾 Saved file tree at: \(filePath)", inline: false)

  //   guard try askUserForFileTreeApproval(fileTree) else {
  //     terminal.printText("🗑️ Deleting file tree...", inline: true)
  //     try FilesRepository.deleteFileTree(in: outDir)
  //     terminal.printText("🗑️ Deleted file tree.", inline: true)
  //     return try await generateProjectFileTree(for: specifications, using: openaiRepository, in: outDir)
  //   }
  //   return fileTree
  // }

  // Store files definitions in the .tmp/artifacts directory, using a hash of the requirements as the filename
  // TODO: If files definitions already exists, ask if user wants to resume using the existing files definitions
  // TODO: If yes, skip file tree generation & file content definitions generation
  // TODO: If no, delete old file tree & old file content definitions, generate new file tree and new file content definitions and store them, along with a hash of the requirements, specifications, and file tree
  func generateProjectFilesDefinitions(for requirements: ProjectRequirements, specifications: ProjectSpecifications, and fileTree: FileTree, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> [FileDefinition] {
    terminal.startTextTimerLoader("📝📄 Generating files definitions... 📑📃", inline: true)

    // TODO: Generate files one or more at a time. This should be controlled here.
    for file in fileTree.outlines {
      terminal.printText("Creating file: \(file.filepath)")
    }

    let filesDefinitionsResults = try await FilesDefinitionsGenerator().generateFilesDefinitions(for: requirements, and: fileTree, using: openaiRepository)
    
    let filesDefinitions: [FileDefinition] = filesDefinitionsResults.reduce([]) {
      switch $1 {
        case let .success(fileDefinition): return $0 + [fileDefinition]
        case let .failure(error):
        if case let .failedGeneratingFileDefinition(filepath) = error as? GenerateError {
          print("Failed generating file definition for file: \(filepath)")
          return $0 + [FileDefinition(filepath: filepath, content: nil)]
        }
        return $0 
      }
    }
    // TODO: Only print that if verbose
    // for definition in filesDefinitions {
    //   terminal.printText("Creating file: \(definition.filepath), with content: \(definition.content ?? "No Content Provided")")
    // }
    let filePath = try FilesRepository.saveFilesDefinitions(filesDefinitions, in: outDir)
  
    terminal.stopTextTimerLoader()

    terminal.printText("💾 Saved files definitions at: \(filePath)", inline: false)
    return filesDefinitions
  }

  // TODO: Store scripts definitions in the .tmp/artifacts directory
  // If scripts definitions already exists, ask if user wants to resume using the existing files definitions
  // If yes, skip scripts definitions generation
  // If no, delete old file scripts definitions, generate new scripts definitions, and store them, along with a hash of the requirements, specifications, and file tree
  func generateProjectScripts(for requirements: ProjectRequirements, specifications: ProjectSpecifications, and fileTree: FileTree, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> ScriptsDefinitions {
    terminal.startTextTimerLoader("📝📄 Generating scripts... 📑📃", inline: true)

    let scriptsDirectory = FilesRepository.Directory.artifacts(outputDirectory: outputDirectory)

    guard let scriptsDefinitions = try await ScriptsDefinitionsGenerator().generateScriptsDefinitions(considering: requirements, and: fileTree, using: openaiRepository) else {
      throw GenerateError.failedGeneratingScriptsDefinitions
    }
    // TODO: Only print that if verbose
    // for scriptDefinition in scriptsDefinitions.beforeFilesCreation {
    //   print("Creating script: \(scriptDefinition.name), with content: \(scriptDefinition.script)")
    // }
    // for scriptDefinition in scriptsDefinitions.afterFilesCreation {
    //   print("Creating script: \(scriptDefinition.name), with content: \(scriptDefinition.script)")
    // }
    try FilesRepository.write(scriptsDefinitions, to: "scripts-definitions.json", in: scriptsDirectory)
  
    terminal.stopTextTimerLoader()

    terminal.printText("💾 Saved scripts at: \(scriptsDirectory.path)/scripts.json", inline: false)
    return scriptsDefinitions
  }

  func run() async throws {
    let outDir = outputDirectory ?? "./"
    defer { errorLogger.outputLogs(at: "\(outDir)/errors.json") }

    do {
      let openaiRepository = OpenaiChatRepository(openaiApiKey: openaiApiKey, endpointURL: openaiEndpointUrl)
      try createOutputDirectory(outDir)
      let requirements = try RequirementsParser().readAndParseRequirements(in: requirementsDirectory)

      print("Artifacts Generation".bold)
      let specifications = try await generateProjectSpecifications(for: requirements, using: openaiRepository, in: outDir)
      let fileTree = try await generateProjectFileTree(for: specifications, using: openaiRepository, in: outDir)
      let filesDefinitions = try await generateProjectFilesDefinitions(for: requirements, specifications: specifications, and: fileTree, using: openaiRepository, in: outDir)
      let scriptsDefinitions = try await generateProjectScripts(for: requirements, specifications: specifications, and: fileTree, using: openaiRepository, in: outDir)
      
      let projectDescription = ProjectDefinition(
        requirements: requirements,
        fileTree: fileTree,
        files: filesDefinitions,
        scripts: scriptsDefinitions
      )
      try FilesRepository.createFile(from: projectDescription, in: .tool(outputDirectory: outDir), named: "project-description.json")

      print("Project description file created in \(outDir) directory")
      
      // TODO: Check if all the files that should have been created have, indeed, been created

      print()
      print("To generate your project file tree and files, run the following command:")
		  print("👉 swift run CLITool build --output-directory \(outDir) --project-definition-path \(FilesRepository.Directory.tool(outputDirectory: outDir).path)/project-description.json")
      print()
    } catch (let error) {
      errorLogger.log(error.localizedDescription)
      throw error
    }
  }
}