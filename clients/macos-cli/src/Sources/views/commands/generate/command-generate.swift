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

  func askUserForDocumentApproval(prompt: String, printDocument: () -> Void) -> Bool {
    let response = terminal.promptForInput(withMessage: "\(prompt) - print (p) / yes (y) / no (n) - (YES)   ")?.lowercased()
      if response == "print" || response == "p" {
        printDocument()
        return askUserForDocumentApproval(prompt: prompt, printDocument: printDocument)
      }
      return response == "yes" || response == "y" || response == "" || response == nil
  }

  func generateDocument<T>(_ documentName: String, textLoaderTitle: String, completionTitle: String, generator: () async throws -> T?, saveDocument: (T) throws -> String, deleteDocument: () throws -> Void, askForDocumentApproval: ((T) async throws -> Bool)?) async throws -> T {
    terminal.startTextTimerLoader(textLoaderTitle, inline: true)
    guard let document = try await generator() else {
      terminal.stopTextTimerLoader()
      throw GenerateError.failedGeneratingDocument(documentName)
    }
    terminal.stopTextTimerLoader()

    terminal.printText(completionTitle, inline: true)
    let filePath = try saveDocument(document)
    terminal.printText("💾 Saved \(documentName) at \(filePath).", inline: false)

    if let askForDocumentApproval {
      guard try await askForDocumentApproval(document) else {
        terminal.printText("🗑️ Deleting \(documentName)...", inline: true)
        try deleteDocument()
        terminal.printText("🗑️ Deleted \(documentName).", inline: false)
        return try await generateDocument(documentName, textLoaderTitle: textLoaderTitle, completionTitle: completionTitle, generator: generator, saveDocument: saveDocument, deleteDocument: deleteDocument, askForDocumentApproval: askForDocumentApproval)
      }
    }
    return document
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
      askForDocumentApproval: { specs in askUserForDocumentApproval(prompt: "Continue, using these specifications?", printDocument: { terminal.printText(specs) }) }
    )
  }

  // Generate the file tree based on the specifications
  // TODO: If file tree already exists, ask if the user wants to reuse it
  // TODO: If yes, skip file tree generation
  // TODO: If no, delete old file tree, generate new file tree and store it, along with a hash of the specifications and the requirements
  func generateProjectFileTree(for specifications: ProjectSpecifications, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> FileTree {
    return try await generateDocument(
      "file tree",
      textLoaderTitle: "🌳🌲 Generating file tree... 🏕️🌴",
      completionTitle: "🌳🌲 Generated file tree.",
      generator: { try await FileTreeGenerator().createFileTree(for: specifications, using: openaiRepository) },
      saveDocument: { try FilesRepository.saveFileTree($0, in: outDir) },
      deleteDocument: { try FilesRepository.deleteFileTree(in: outDir) },
      askForDocumentApproval: { fileTree in askUserForDocumentApproval(prompt: "Continue, using this file tree?", printDocument: { terminal.printCodable(fileTree) }) }
    )
  }

  // Store files definitions in the .tmp/artifacts directory, using a hash of the requirements as the filename
  // TODO: If files definitions already exists, ask if user wants to resume using the existing files definitions
  // TODO: If yes, skip file tree generation & file content definitions generation
  // TODO: If no, delete old file tree & old file content definitions, generate new file tree and new file content definitions and store them, along with a hash of the requirements, specifications, and file tree
  func generateProjectFilesDefinitions(for requirements: ProjectRequirements, specifications: ProjectSpecifications, and fileTree: FileTree, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> [FileDefinition] {
    return try await generateDocument(
      "files definitions",
      textLoaderTitle: "📝📄 Generating files definitions... 📑📃",
      completionTitle: "📝📄 Generated files definitions.",
      generator: {
        let results = try await FilesDefinitionsGenerator().generateFilesDefinitions(for: requirements, and: fileTree, using: openaiRepository)
        return results.reduce([]) {
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
      },
      saveDocument: { try FilesRepository.saveFilesDefinitions($0, in: outDir) },
      deleteDocument: { },
      askForDocumentApproval: nil
    )
  }

  // TODO: Store scripts definitions in the .tmp/artifacts directory
  // If scripts definitions already exists, ask if user wants to resume using the existing files definitions
  // If yes, skip scripts definitions generation
  // If no, delete old file scripts definitions, generate new scripts definitions, and store them, along with a hash of the requirements, specifications, and file tree
  func generateProjectScriptsDefinitions(for requirements: ProjectRequirements, specifications: ProjectSpecifications, and fileTree: FileTree, using openaiRepository: OpenaiChatRepository, in outDir: String) async throws -> ScriptsDefinitions {
    return try await generateDocument(
      "scripts definitions",
      textLoaderTitle: "📝📄 Generating scripts... 📑📃",
      completionTitle: "📝📄 Generated scripts.",
      generator: { try await ScriptsDefinitionsGenerator().generateScriptsDefinitions(considering: requirements, and: fileTree, using: openaiRepository) },
      saveDocument: { try FilesRepository.saveScriptsDefinitions($0, in: outDir) },
      deleteDocument: { },
      askForDocumentApproval: nil
    )
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
      let scriptsDefinitions = try await generateProjectScriptsDefinitions(for: requirements, specifications: specifications, and: fileTree, using: openaiRepository, in: outDir)
      
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