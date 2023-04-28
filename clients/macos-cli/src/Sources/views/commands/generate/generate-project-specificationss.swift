import Foundation

extension Generate {
	class ProjectSpecificationsGenerator {
		private let systemPrompt = """
		You are TODD, a programming tool, and a software engineer's best friend.
		When provided with a project's requirements, you generate the project's specifications.

		These specifications should be written in Markdown.
		These specifications should be detailed enough to allow a software engineer to implement the project's requirements.
		These specifications should be written in a way that allows a software engineer to implement the project's requirements in any programming language.
		These specifications should mention accessiblity requirements & best practices.
		These specifications should mention localization requirements & best practices.
		These specifications should place a strong emphasis on the technical requirements and reiterate them at least once.

		Generate extensive specifications for the following project requirements.

		REQUIREMENTS:
		"""
		
		private func userMessagePrompt(from requirements: ProjectRequirements) throws -> String {
			let userMessageJsonData = try JSONEncoder().encode(requirements)
			guard let userMessageJsonString = String(data: userMessageJsonData, encoding: .utf8) else {
				throw GenerateError.failedEncodingRequirements
			}
			return userMessageJsonString
		}

		private func openaiMessages(from requirements: ProjectRequirements) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemPrompt),
				.init(role: .user, content: try userMessagePrompt(from: requirements))
			]
		}

		private func specs(from message: OpenaiChatRepository.Message) throws -> String? {
			return message.content
		}

		func createSpecs(for requirements: ProjectRequirements, using repository: OpenaiChatRepository) async throws -> String? {
			let messages = try openaiMessages(from: requirements)
			guard let response = try await repository.send(messages) else {
				return nil
			}
			return try specs(from: response)
		}
	}
}