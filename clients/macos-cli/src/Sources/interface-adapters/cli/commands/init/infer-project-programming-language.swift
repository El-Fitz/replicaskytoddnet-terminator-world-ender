import Foundation

extension Init {
	class ProjectProgrammingLanguageInferenceEngine {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's functional requirements, description, and technical environment, following the current industry best practices, you return the best suited programming language for the described project.
		You should suggest only one programming language.

		For example if the project is a frontend web application, you could suggest "TypeScript", or "JavaScript", or anything else that is suitable for the described project.
		For a backend project, you could suggest ".NET, C#", "TypeScript", "Elixir", "Go", "Rust", or "Java", or anything else that is suitable for the described project.
		As another example, if the project is a mobile application, you could suggest "Swift", "Kotlin", or "TypeScript", or anything else that is suitable for the described project.

		If the project is a multiplatform application, suggest a language that can be used for all platforms.
		
		Return the best suited programming language for the project described below.

		"""

		private func userMessagePrompt(for functionalRequirements: DefinitionFunctionalRequirements, and environment: String) throws -> String {
			return """
			Functional Requirements:
			\(functionalRequirements)

			Technical Requirements:
			Environment: \(environment)
			"""
		}

		private func openaiMessages(for functionalRequirements: DefinitionFunctionalRequirements, and environment: String) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(for: functionalRequirements, and: environment))
			]
		}

		private func name(from message: OpenaiChatRepository.Message) throws -> String {
			return message.content
		}

		func infer(for functionalRequirements: DefinitionFunctionalRequirements, and environment: String, using repository: OpenaiChatRepository) async throws -> String? {
			let messages = try openaiMessages(for: functionalRequirements, and: environment)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try name(from: response)
		}
	}
}