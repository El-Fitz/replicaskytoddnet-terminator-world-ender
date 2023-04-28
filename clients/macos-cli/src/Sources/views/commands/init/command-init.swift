import Foundation
import Rainbow

extension Init {

	enum TechnicalRequirement: String {
		case language
		case architecture
		case environment
		case frameworks
	}
	func getOptionalUserInput(prompt: String) -> String? {
    print(prompt.cyan, terminator: " (Optional):\n")
    let input = readLine(strippingNewline: true)
		if !(input ?? "").isEmpty {
			print()
		}
		if input?.isEmpty == true {
			return nil
		}
    return input
	}

	func moveCursorUp(lines: Int) {
    print("\u{1B}[\(lines)A", terminator: "")
	}

	func clearLine() {
    print("\u{1B}[2K", terminator: "")
	}

	func clearPreviousLines(lines: Int) {
		for _ in 0..<lines {
			moveCursorUp(lines: 1)
			clearLine()
		}
	}

	func getRequiredUserInput(prompt: String, minLength: Int, isFirstInvocation: Bool = true) -> String {
    if !isFirstInvocation {
        clearPreviousLines(lines: 2)
    }
    print(prompt.cyan, terminator: " (Required):\n")
    guard let input = readLine(strippingNewline: true), input.count >= minLength else {
        return getRequiredUserInput(prompt: prompt.onRed, minLength: minLength, isFirstInvocation: false)
    }
		if !input.isEmpty {
			print()
		}
    return input
	}

	func printUpdatingLines(_ lines: [String]) {
		for line in lines {
      clearPreviousLines(lines: 1)
			print(line)
    	usleep(300000)
		}
	}

	func getProjectsFunctionalDescription() -> String {
		let projectFunctionalDescription = getRequiredUserInput(prompt: "\("🏗️  What is your project's functional description?".bold) (e.g. A mobile app that allows users to create and share recipes)", minLength: 10)
		return projectFunctionalDescription
	}

	func getProjectsFunctionalRequirements() -> (name: String?, description: String) {
		let projectName = getOptionalUserInput(prompt: "\("👶  What is your project's name?".bold) (e.g. MyProject) Leave empty if you want us to generate one for you")
		let projectFunctionalDescription = getProjectsFunctionalDescription()
		return (name: projectName, description: projectFunctionalDescription)
	}

	func inferProjectProgrammingLanguage(for functionalRequirements: String, and environment: String, using openaiRepository: OpenaiChatRepository) async throws -> String? {
		print("Infering best suited programming language...")
		if let generatedLanguage = (try await ProjectProgrammingLanguageInferenceEngine().infer(for: functionalRequirements, and: environment, using: openaiRepository)) {
			clearPreviousLines(lines: 1)
			print("✅  Programming language: ".bold, generatedLanguage.green.bold)
			print()
			return generatedLanguage
		}
		return nil
	}

	func inferProjectArchitecture(for functionalRequirements: String, and programmingLanguage: String, using openaiRepository: OpenaiChatRepository) async throws -> String? {
		print("Infering best suited architecture...")
		if let architecture = (try await ProjectArchitectureInferenceEngine().infer(for: functionalRequirements, and: programmingLanguage, using: openaiRepository)) {
			clearPreviousLines(lines: 1)
			print("✅  Architecture: ".bold, architecture.green.bold)
			print()
			return architecture
		}
		return nil
	}

	func inferProjectTooling(for functionalRequirements: String, and programmingLanguage: String, using openaiRepository: OpenaiChatRepository) async throws -> String? {
		print("Infering best suited tools and framework...")
		if let tooling = (try await ProjectFrameworkInferenceEngine().infer(for: functionalRequirements, and: programmingLanguage, using: openaiRepository)) {
			clearPreviousLines(lines: 1)
			print("✅  Tools & Frameworks: ".bold, tooling.green.bold)
			print()
			return tooling
		}
		return nil
	}

	func inferProjectEnvironment(for functionalRequirements: String, using openaiRepository: OpenaiChatRepository) async throws -> String? {
		print("Infering the most likely technical environment...")
		if let environment = (try await ProjectEnvironmentferenceEngine().infer(for: functionalRequirements, using: openaiRepository)) {
			clearPreviousLines(lines: 1)
			print("✅  Environment: ".bold, environment.green.bold)
			print()
			return environment
		}
		return nil
	}

	func getProjectTechnicalRequirements(for functionalRequirements: String, using openaiRepository: OpenaiChatRepository) async throws -> DefinitionTechnicalRequirements {
		let userProvidedEnvironment = getOptionalUserInput(prompt: "\("🏞️  What will be your project's technical environment?".bold) (e.g. iOS, macOS, tvOS, watchOS, web app, serverless backend, etc.)")
		clearPreviousLines(lines: 2)
		let userProvidedLanguage = getOptionalUserInput(prompt: "\("💬  What programming language do you want to use?".bold) (e.g. Swift, Objective-C, JavaScript, TypeScript, Python, Ruby, etc.)")
		clearPreviousLines(lines: 2)
		let userProvidedArchitecture = getOptionalUserInput(prompt: "\("🗼  What architecture and architectural patterns do you want to use?".bold) (e.g. MVC, MVVM, VIPER, Clean, Hexagonal, Atomic Design components, etc.)")
		clearPreviousLines(lines: 2)
		let userProvidedFrameworks = getOptionalUserInput(prompt: "\("🛠️  What tools frameworks do you want to use?".bold) (e.g. SwiftUI, UIKit, Vapor, React, SveleteKit, Node.js, Deno, Express etc.)")
		clearPreviousLines(lines: 2)

		let environment: String = try await {
			if let userProvidedEnvironment = userProvidedEnvironment {
				return userProvidedEnvironment
			} else {
				return try await inferProjectEnvironment(for: functionalRequirements, using: openaiRepository)
			}
		}() ?? ""

		let programmingLanguage: String = try await {
			if let userProvidedLanguage = userProvidedLanguage {
				return userProvidedLanguage
			} else {
				return try await inferProjectProgrammingLanguage(for: functionalRequirements, and: environment, using: openaiRepository)
			}
		}() ?? ""

		async let architecture: String? = {
			if let userProvidedArchitecture = userProvidedArchitecture {
				return userProvidedArchitecture
			} else {
				return try await inferProjectArchitecture(for: functionalRequirements, and: programmingLanguage, using: openaiRepository)
			}
		}()

		async let frameworks: String? = {
			if let userProvidedFrameworks = userProvidedFrameworks {
				return userProvidedFrameworks
			} else {
				return try await inferProjectTooling(for: functionalRequirements, and: programmingLanguage, using: openaiRepository)
			}
		}()

		clearPreviousLines(lines: 9)
		print("Technical Requirements".capitalized.bold)
		print("✅  Environment 🌄 ".bold, programmingLanguage.green.bold)
		print("✅  Programming language 🗣️ ".bold, environment.green.bold)
		print("✅  Architecture 🗼 ".bold, try await architecture?.green.bold ?? "None")
		print("✅  Tools & Frameworks 🛠️ ".bold, try await frameworks?.green.bold ?? "None")

		return try await [
			TechnicalRequirement.environment.rawValue: environment,
			TechnicalRequirement.language.rawValue: programmingLanguage,
			TechnicalRequirement.architecture.rawValue: architecture ?? "",
			TechnicalRequirement.frameworks.rawValue: frameworks ?? ""
		]
	}

	fileprivate func projectDescription(from name: String, and functionalRequirements: String) -> String {
		return """
		# Project Name: \(name)
		\(functionalRequirements)
		"""
	}

	func inferProjectName(for functionalRequirements: String, using openaiRepository: OpenaiChatRepository) async throws -> String {
				print("Generating project name...")
		if let generatedName = (try await ProjectNameInferenceEngine().infer(for: functionalRequirements, using: openaiRepository)) {
			clearPreviousLines(lines: 4)
			print("Your project name will be... 🥁🥁🥁:\n".bold)
			print("🎉🍾 - \(generatedName.green.bold) - 🎇 😎")
			print()
			return generatedName
		} else {
			clearPreviousLines(lines: 4)
			print("Failed to generate a name. Defaulting to MyProject. 😕")
			return "MyProject"
		}
	}

	func getProjectRequirementsDefinitions(openaiRepository: OpenaiChatRepository) async throws -> DefinitionRequirements {
		let (userProvidedProjectName, functionalRequirements) = getProjectsFunctionalRequirements()
		let technicalRequirements = try await getProjectTechnicalRequirements(for: functionalRequirements, using: openaiRepository)

		let projectName = try await {
			if let userProvidedProjectName = userProvidedProjectName, userProvidedProjectName.count > 0 {
				return userProvidedProjectName
			} else {
				return try await inferProjectName(for: functionalRequirements, using: openaiRepository)
			}
		}()

		let functionalDescription = projectDescription(from: projectName, and: functionalRequirements)
		return DefinitionRequirements(functional: functionalDescription, technical: technicalRequirements)
	}

	func save(_ functionalRequirements: DefinitionFunctionalRequirements, outputDirectory: String) throws {
		try FilesRepository.write(stringContent: functionalRequirements, to: "functional-requirements.md", in: .requirements(outputDirectory: outputDirectory))
	}

	func save(_ technicalRequirements: DefinitionTechnicalRequirements, outputDirectory: String) throws {
		try FilesRepository.write(technicalRequirements, to: "technical-requirements.json", in: .requirements(outputDirectory: outputDirectory))
	}

	func run() async throws {
		
		let outputDirectory = getOptionalUserInput(prompt: "\("🏡  Where do you want to create your project?".bold) (e.g. ./)") ?? "./"
		defer { errorLogger.outputLogs(at: "\(outputDirectory)/errors.json") }
		let openaiRepository = OpenaiChatRepository(openaiApiKey: openaiApiKey, endpointURL: openaiEndpointUrl)
		// TODO: Check if the requirements files already exist in outputDirectory
		// If yes, ask the user if they want to overwrite them
		// If they do, overwrite them
		// If they don't, ask them to choose a different outputDirectory
		// If no, exit
		let requirements = try await getProjectRequirementsDefinitions(openaiRepository: openaiRepository)

		try save(requirements.functional, outputDirectory: outputDirectory)
		try save(requirements.technical, outputDirectory: outputDirectory)

		print("Requirements successfully saved to \(outputDirectory)/.replicaskytoddnetinator/requirements/ 🎉")
		print()
		print("To generate your project file tree and files, run the following command:")
		print("👉 swift run CLITool generate --output-directory \(outputDirectory) --requirements-directory \(outputDirectory)/.replicaskytoddnetinator/requirements/")
		print()
	}
}