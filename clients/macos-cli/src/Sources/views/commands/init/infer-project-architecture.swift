import Foundation

extension Init {
	class ProjectArchitectureInferenceEngine {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's functional requirements, description and programming language, following the current industry best practices, you return a simple comma separated list of the most appropriate architecture and / or architecture patterns for the described project.
		You should suggest only one architecture at a time.
		You can also simply return an empty string.

		For example if the project is a frontend web application, you could suggest "Redux" or "Clean Architecture, Atomic Design Components", or anything else that is suitable for the described project.
		As another example, if the project is an iOS application, you could suggest "MVVM, Atomic Design Components", "MVC", "VIPER", or "Clean Architecture", or anything else that is suitable for the described project.
		
		Return a simple comma separated list of the most appropriate architecture and / or architecture patterns for the project described below.

		"""

		private func userMessagePrompt(for functionalRequirements: DefinitionFunctionalRequirements, and programmingLanguage: String) throws -> String {
			return """
			Functional Requirements:
			\(functionalRequirements)

			Technical Requirements:
			Programming Language: \(programmingLanguage)
			"""
		}

		private func openaiMessages(for functionalRequirements: DefinitionFunctionalRequirements, and programmingLanguage: String) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(for: functionalRequirements, and: programmingLanguage))
			]
		}

		private func name(from message: OpenaiChatRepository.Message) throws -> String {
			return message.content
		}

		func infer(for functionalRequirements: DefinitionFunctionalRequirements, and programmingLanguage: String, using repository: OpenaiChatRepository) async throws -> String? {
			let messages = try openaiMessages(for: functionalRequirements, and: programmingLanguage)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try name(from: response)
		}
	}
}