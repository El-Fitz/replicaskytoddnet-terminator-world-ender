import Foundation

extension Init {
	class ProjectFrameworkInferenceEngine {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's functional requirements, description and programming language, following the current industry best practices, you return a simple comma separated list of the most appropriate tools and / or frameworks for the picked programming language and described project.
		You can also simply return an empty string.

		For example if the project is a frontend web application, you could suggest "React", "Vue.js", or "Svelte", or anything else that is suitable for the described project, and is available for the picked programming language.
		For a serverless backend project, you could suggest "AWS Lambda, DynamoDB", "DynamoDB", "Firebase", "Google Cloud Functions", or anything else or any combination that is suitable for the described project, and is available for the picked programming language.
		For a backend project, you could suggest "Express", "Fastify", "Koa", "NestJS", "PostreSQL", "Redis", or anything else that is suitable for the described project, and is available for the picked programming language.
		As another example, if the project is an iOS application, you could suggest "CoreData", "SwiftUI", "UIKit", "Realm", or anything else that is suitable for the described project, and is available for the picked programming language.
		As another example, if the project is a multiplatform mobile app, you could suggest "ReactNative", or anything else that is suitable for the described project, and is available for the picked programming language.
		
		If the project is multiplatform, only suggest tools and / or frameworks that are suitable for and available on all platforms, using the prescribed programming language.

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