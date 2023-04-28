import Foundation

extension Init {
	class ProjectEnvironmentferenceEngine {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's functional requirements and description, following the current industry best practices, you return a simple comma separated list of the most probable environment or environments for the described project.
		You can also simply return an empty string.

		For example if the project is a frontend web application, you could suggest "Chrome", "Safari", or "Svelte", or anything else or any combination that is suitable for the described project.
		For a backend project, you could suggest "Serverless", "AWS", "Firebase", "Google Cloud Platform", "Linux", "Docker", "Kubernetes", or anything else or any combination that is suitable for the described project.
		As another example, if the project is an iOS application, you could suggest "iOS", "iPad", or anything else or any combination that is suitable for the described project.
		As another example, if the project is a mobile application, you could suggest "iOS", "Android", "hybrid mobile app", or anything else or any combination that is suitable for the described project.
		As another example, if the project is a desktop app or a cli tool, you could suggest "Linux", "macOS", "Windows", or anything else or any combination that is suitable for the described project.
		
		IF the project is multiplatform, indicate that in the response, and only suggest environments that are suitable for and available on all platforms.
		Return a simple comma separated list of the most appropriate architecture and / or architecture patterns for the project described below.

		"""

		private func userMessagePrompt(for functionalRequirements: DefinitionFunctionalRequirements) throws -> String {
			return """
			Functional Requirements:
			\(functionalRequirements)
			"""
		}

		private func openaiMessages(for functionalRequirements: DefinitionFunctionalRequirements) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(for: functionalRequirements))
			]
		}

		private func name(from message: OpenaiChatRepository.Message) throws -> String {
			return message.content
		}

		func infer(for functionalRequirements: DefinitionFunctionalRequirements, using repository: OpenaiChatRepository) async throws -> String? {
			let messages = try openaiMessages(for: functionalRequirements)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try name(from: response)
		}
	}
}