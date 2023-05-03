import Foundation
import CryptoKit

extension Generate {
	class FileTreeGenerator {
		private let systemSetUpPrompt = """
		You are TODD, a JSON API.
		When provided with a project's specifications, you strictly follow these specifications and return the file tree needed for the described project, along with an outline and an extensive description of the classes, functions, structures and methods declared in each file, separately.
		
		Use the JSON template below.

		No prose.
		==========
		TEMPLATE:
		[{"filepath": "relativeFilePathToFileFromProjectRootDirectory", "outline": ["file's content outline"], "description": "an extensive markdown description of the file's content, and for source code files, the purpose & behaviour of the file's code" }]
		
		"""

		private let systemClosingPrompt = """

		Return the file tree needed for the described project, along with an outline and a description of the classes, functions, structures and methods declared in each file, separately.
		
		Use the JSON template below.

		No prose.
		==========
		TEMPLATE:
		[{"filepath": "relativeFilePathToFileFromProjectRootDirectory", "outline": ["file's content outline"], "description": "a markdown description of the file's content, and for source code files, the purpose & behaviour of the file's code" }]
		"""
		
		private func userMessagePrompt(from requirements: ProjectRequirements) throws -> String {
			let userMessageJsonData = try JSONEncoder().encode(requirements)
			guard let userMessageJsonString = String(data: userMessageJsonData, encoding: .utf8) else {
				throw GenerateError.failedEncodingRequirements
			}
			return userMessageJsonString
		}

		private func userMessagePrompt(from specifications: ProjectSpecifications) throws -> String {
			return specifications
		}

		private func openaiMessages(from requirements: ProjectRequirements) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(from: requirements)),
				.init(role: .system, content: systemClosingPrompt)
			]
		}

		private func openaiMessages(from specifications: ProjectSpecifications) throws -> [OpenaiChatRepository.Message] {
			return [
				.init(role: .system, content: systemSetUpPrompt),
				.init(role: .user, content: try userMessagePrompt(from: specifications)),
				.init(role: .system, content: systemClosingPrompt)
			]
		}

		private func filesOutlines(from message: OpenaiChatRepository.Message) throws -> [FileOutline]? {
			guard let data = message.content.data(using: .utf8) else {
				return nil
			}
			return try JSONDecoder().decode([FileOutline].self, from: data)
		}

		func createFileTree(for requirements: ProjectRequirements, using repository: OpenaiChatRepository) async throws -> FileTree? {
			let messages = try openaiMessages(from: requirements)
			guard let response = try await repository.send(messages), let outlines = try filesOutlines(from: response) else {
				return nil
			}
			let requirementsData = (try JSONEncoder().encode(requirements))
			return .init(outlines: outlines, requirementsHash: CryptoKit.SHA256.hash(data: requirementsData).description)
		}

		func createFileTree(for specifications: ProjectSpecifications, using repository: OpenaiChatRepository) async throws -> FileTree? {
			let messages = try openaiMessages(from: specifications)
			guard let response = try await repository.send(messages), let outlines = try filesOutlines(from: response) else {
				return nil
			}
			let requirementsData = (try JSONEncoder().encode(specifications))
			return .init(outlines: outlines, requirementsHash: CryptoKit.SHA256.hash(data: requirementsData).description)
		}
	}
}