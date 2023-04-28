import Foundation

enum FileError: Error {
    case directoryNotFound
}


// TODO: The FilesRepository should know, given a root directory, where to find & write the different files
struct FilesRepository {
    enum Directory {
        case root(outputDirectory: String?)
        case custom(outputDirectory: String?, path: String)
        case tool(outputDirectory: String?)
        case requirements(outputDirectory: String?)
        case artifacts(outputDirectory: String?)

        var subpath: String {
            switch self {
                case .root: return ""
                case .custom(_, let customPath): return "\(customPath)"
                case .tool: return ".replicaskytoddnetinator"
                case .requirements: return ".replicaskytoddnetinator/requirements"
                case .artifacts: return ".replicaskytoddnetinator/.tmp/artifacts"
            }
        }

        var rootOutputDirectory: String {
            switch self {
                case let .root(outputDirectory):
                return outputDirectory ?? "./"
                case .custom(let outputDirectory, _):
                return outputDirectory ?? "./"
                case let .tool(outputDirectory):
                return outputDirectory ?? "./"
                case let .requirements(outputDirectory):
                return outputDirectory ?? "./"
                case let .artifacts(outputDirectory):
                return outputDirectory ?? "./"
            }
        }

        var path: String {
            return "\(rootOutputDirectory)/\(subpath)"
        }
    }

    enum Files {
        case fileTree
        case projectSpecifications
        case projectDefinition
    }

    static func deleteFile(fileName: String, in directory: Directory) throws {
        let fileURL = URL(fileURLWithPath: directory.path).appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: fileURL)
    }

	static func listFilesWithExtension(in directoryPath: String, matching fileExtension: String) throws -> [URL] {
        let fileManager = FileManager.default

        guard let url = URL(string: directoryPath) else {
            throw FileError.directoryNotFound
        }

        guard fileManager.fileExists(atPath: url.path) else {
            throw FileError.directoryNotFound
        }

        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        let matchingFiles = contents.filter { fileURL in
            let filePath = fileURL.path
            let fileExtensionWithDot = ".\(fileExtension)"
            
            if let range = filePath.range(of: fileExtensionWithDot, options: [.backwards]) {
                let indexAfterExtension = filePath.index(range.upperBound, offsetBy: 0)
                return indexAfterExtension == filePath.endIndex
            }
            
            return false
        }
        return matchingFiles
	}

	static func write(stringContent: String, to fileName: String, in directory: Directory) throws {
		let fileURL = URL(fileURLWithPath: directory.path).appendingPathComponent(fileName)
		try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try stringContent.write(to: fileURL, atomically: true, encoding: .utf8)
	}

    static func write<T: Codable>(_ content: T, to fileName: String, in directory: Directory) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(content)
        let json = String(data: data, encoding: .utf8)!
		let fileURL = URL(fileURLWithPath: directory.path).appendingPathComponent(fileName)
		try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try json.write(to: fileURL, atomically: true, encoding: .utf8)
	}

	static func readTypedFile<T: Codable>(_ type: T.Type, at path: String) throws -> T {
		let data = try Data(contentsOf: URL(fileURLWithPath: path))
		let object = try JSONDecoder().decode(T.self, from: data)
		return object
	}

    private static func fileOutline(for outline: [String]?, fileTree: FileTree, filepath: String) -> String {
        if let outline = fileTree.outlines.first(where: { $0.filepath == filepath })?.outline, outline.count  > 0 {
            return outline.map() { " * - \( $0 )" }.joined(separator: "\n")
        }
        return " * No outline provided"
        
    }

    private static func fileContent(for outline: [String], fileTree: FileTree, filepath: String) -> String {
        return """
		// Failed to generate content for file: \(filepath)
		/**
		 * File Outline:
		 \(fileOutline(for: outline, fileTree: fileTree, filepath: filepath))
		 *
		**/
		"""
    }

    static func createFiles(from filesDefinitions: [FileDefinition], fileTree: FileTree, in directory: Directory) throws {
        for fileDefinition in filesDefinitions {
            if let content = fileDefinition.content {
                try FilesRepository.write(stringContent: content, to: fileDefinition.filepath, in: directory)
            } else {
                let outline = fileTree.outlines.first(where: { $0.filepath == fileDefinition.filepath })?.outline
                let content = fileOutline(for: outline, fileTree: fileTree, filepath: fileDefinition.filepath)
                try FilesRepository.write(stringContent: content, to: fileDefinition.filepath, in: directory)
            }
        }
    }

    static func createFile(from projectDefinition: ProjectDefinition, in directory: Directory, named fileName: String = "project.json") throws {
        try FilesRepository.write(projectDefinition, to: fileName, in: directory)
    }

    private static func saveString(_ content: String, in directory: Directory, named fileName: String) throws -> String{
        try FilesRepository.write(stringContent: content, to: fileName, in: directory)
        return "\(directory.path)/\(fileName)"
    }
    
    private static func saveCodable<T: Codable>(_ content: T, in directory: Directory, named fileName: String) throws -> String{
        try FilesRepository.write(content, to: fileName, in: directory)
        return "\(directory.path)/\(fileName)"
    }

    static func saveFunctionalRequirements(_ functionalRequirements: DefinitionFunctionalRequirements, in outputDirectory: String) throws -> String {
        return try saveString(functionalRequirements, in: .requirements(outputDirectory: outputDirectory), named: "functional-requirements.md")
    }

    static func retrieveFunctionalRequirements(from outputDirectory: String) -> DefinitionFunctionalRequirements? {
        return try? FilesRepository.readTypedFile(DefinitionFunctionalRequirements.self, at: Directory.requirements(outputDirectory: outputDirectory).path + "/functional-requirements.json")
    }

    static func saveTechnicalRequirements(_ technicalRequirements: DefinitionTechnicalRequirements, in outputDirectory: String) throws -> String {
        return try saveCodable(technicalRequirements, in: .requirements(outputDirectory: outputDirectory), named: "technical-requirements.json")
    }

    static func retrieveTechnicalRequirements(from outputDirectory: String) -> DefinitionTechnicalRequirements? {
        return try? FilesRepository.readTypedFile(DefinitionTechnicalRequirements.self, at: Directory.requirements(outputDirectory: outputDirectory).path + "/technical-requirements.json")
    }

    static func saveProjectSpecifications(_ projectSpecifications: ProjectSpecifications, in outputDirectory: String) throws -> String {
        return try saveString(projectSpecifications, in: .tool(outputDirectory: outputDirectory), named: "project-specifications.md")
    }

    static func retrieveProjectSpecifications(from outputDirectory: String) -> ProjectSpecifications? {
        return try? FilesRepository.readTypedFile(ProjectSpecifications.self, at: Directory.tool(outputDirectory: outputDirectory).path + "/project-specifications.md")
    }

    static func deleteProjectSpecifications(in outputDirectory: String) throws {
        try FileManager.default.removeItem(atPath: Directory.tool(outputDirectory: outputDirectory).path + "/project-specifications.md")
    }

    static func saveFileTree(_ fileTree: FileTree, in outputDirectory: String) throws -> String {
        return try saveCodable(fileTree, in: .artifacts(outputDirectory: outputDirectory), named: "file-tree.json")
    }

    static func retrieveFileTree(from outputDirectory: String) -> FileTree? {
        return try? FilesRepository.readTypedFile(FileTree.self, at: Directory.artifacts(outputDirectory: outputDirectory).path + "/file-tree.json")
    }

    static func deleteFileTree(in outputDirectory: String) throws {
        try FileManager.default.removeItem(atPath: Directory.artifacts(outputDirectory: outputDirectory).path + "/file-tree.json")
    }

    static func saveFilesDefinitions(_ filesDefinitions: [FileDefinition], in outputDirectory: String) throws -> String {
        return try saveCodable(filesDefinitions, in: .artifacts(outputDirectory: outputDirectory), named: "files-definitions.json")
    }

    static func retrieveFilesDefinitions(from outputDirectory: String) -> [FileDefinition]? {
        return try? FilesRepository.readTypedFile([FileDefinition].self, at: Directory.artifacts(outputDirectory: outputDirectory).path + "/files-definitions.json")
    }

    static func saveScriptsDefinitions(_ scriptsDefinitions: ScriptsDefinitions, in outputDirectory: String) throws -> String {
        return try saveCodable(scriptsDefinitions, in: .artifacts(outputDirectory: outputDirectory), named: "scripts-definitions.json")
    }

    static func retrieveScriptsDefinitions(from outputDirectory: String) -> [ScriptDefinition]? {
        return try? FilesRepository.readTypedFile([ScriptDefinition].self, at: Directory.artifacts(outputDirectory: outputDirectory).path + "/scripts-definitions.json")
    }

    static func saveProjectDefinition(_ projectDefinition: ProjectDefinition, in outputDirectory: String) throws -> String {
        return try saveCodable(projectDefinition, in: .artifacts(outputDirectory: outputDirectory), named: "project-definition.json")
    }

    static func retrieveProjectDefinition(from outputDirectory: String) -> ProjectDefinition? {
        return try? FilesRepository.readTypedFile(ProjectDefinition.self, at: Directory.tool(outputDirectory: outputDirectory).path + "/project-definition.json")
    }
}