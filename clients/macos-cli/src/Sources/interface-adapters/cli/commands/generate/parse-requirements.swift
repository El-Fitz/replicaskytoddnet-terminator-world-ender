import Foundation

extension Generate {
	struct RequirementsParser {
		fileprivate func readAndParseFunctionalRequirementsFile(in directoryPath: String) throws -> DefinitionFunctionalRequirements {
			print("🔎 Looking for functional requirements")
			let data = try Data(contentsOf: URL(fileURLWithPath: directoryPath  + "/functional-requirements.md"))
			guard let content = String(data: data, encoding: .utf8) else {
				throw FileError.directoryNotFound
			}
			print("✅ Found functional requirements")
			return content
		}

		fileprivate func readAndParseTechnicalRequirementsFile(in directoryPath: String) throws -> DefinitionTechnicalRequirements {
			print("🔎 Looking for technical requirements")
			let technicalRequirements = try FilesRepository.readTypedFile(DefinitionTechnicalRequirements.self, at: directoryPath + "/technical-requirements.json")
			print("✅ Found technical requirements")
			return technicalRequirements
		}
		
		fileprivate func listTemplatesFiles(in directoryPath: String) throws -> [URL] {
			print("🔎 Looking for templates")
			do {
				let templates = try FilesRepository.listFilesWithExtension(in: directoryPath, matching: "template.json")
				print("✅ Found templates")
				return templates
			} catch {
				print("No templates provided")
				if case FileError.directoryNotFound = error {
					return []
				}
				throw(error)
			}
		}

		fileprivate func readTemplateFile(at url: URL) throws -> String {
			return try String(contentsOf: url)
		}

		fileprivate func readTemplateFiles(in directoryPath: String) throws -> [RequirementsTemplate] {
			let templateFiles = try listTemplatesFiles(in: directoryPath)
			return try templateFiles.map { url in
				let template = try readTemplateFile(at: url)
				return RequirementsTemplate(name: url.lastPathComponent.uppercased(), template: template)
			}
		}

		func readAndParseRequirements(in directoryPath: String) throws -> ProjectRequirements {
			print()
			print("Requirements".bold)
			print("🔎 Looking for requirements")
			let functionalRequirements = try readAndParseFunctionalRequirementsFile(in: directoryPath)
			let technicalRequirements = try readAndParseTechnicalRequirementsFile(in: directoryPath)
			let templates = try readTemplateFiles(in: directoryPath + "/templates")
			print("✅ Requirements Found")
			print()
			return ProjectRequirements(requirements: ProjectRequirementsDefinition(functional: functionalRequirements, technical: technicalRequirements), templates: templates)
		}
	}
}