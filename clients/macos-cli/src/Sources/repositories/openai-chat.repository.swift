import Foundation

struct OpenaiChatRepository {
	enum OpenaiChatRepositoryError: Error {
		case failedToGetResponse(URLResponse?)
	}

	struct Message: Codable {
		enum Role: String, Codable {
			case assistant
			case system
			case user
		}

		let role: Role
		let content: String
	}

	enum Model: String, Codable {
		case gpt4_8k = "gpt-4"
	}

	private struct RequestBody: Codable {
		let model: Model
		let temperature: Double
		let max_tokens: Int
		let n: Int
		let messages: [Message]

		public init(model: Model = .gpt4_8k, temperature: Double = 0.9, max_tokens: Int = 4000, n: Int = 1, messages: [Message]) {
			self.model = model
			self.temperature = temperature
			self.max_tokens = max_tokens
			self.n = n
			self.messages = messages
		}
	}

	private struct ResponseBody: Codable {
		fileprivate struct Usage: Codable {
			let prompt_tokens: Int
			let completion_tokens: Int
			let total_tokens: Int
		}
	
		fileprivate struct Choice: Codable {
			let message: Message
		}
		fileprivate let choices: [Choice]
		fileprivate let usage: Usage
	}

	let openaiApiKey: String
	let endpointURL: URL

	/*
	 *
	 * This function allows us to implement a sort of exponential backoff
	 * algorithm to retry requests that fail due to rate limiting.
	 *
	 * @param backOffDelay: The delay in seconds before retrying the request
	 */
	func send(_ request: URLRequest, backOffDelay: TimeInterval = 0, tries: Int = 0, retryLimit: Int = 5) async throws -> (Data, URLResponse?) {
		let (data, response) = try await URLSession.shared.data(for: request)
		if backOffDelay > 0 {
			print("Waiting \(backOffDelay) seconds before retrying request...")
			try await Task.sleep(nanoseconds: UInt64(backOffDelay) * 1_000_000_000)
		}
		if let response = response as? HTTPURLResponse, response.statusCode != 200 {
			switch response.statusCode {
				case 429 where tries < retryLimit:
					return try await send(request, backOffDelay: backOffDelay == 0 ? 60 : backOffDelay * 1.5, tries: tries + 1, retryLimit: retryLimit)
				default:
					throw OpenaiChatRepositoryError.failedToGetResponse(response)
			}
		}
		return (data, response)
	}

	func send(_ messages: [Message]) async throws -> Message? {
		var request = URLRequest(url: endpointURL)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(openaiApiKey)", forHTTPHeaderField: "Authorization")
		request.httpBody = try JSONEncoder().encode(RequestBody(messages: messages))
		request.timeoutInterval = 360

		let (data, _) = try await send(request)
		let responseBody = try JSONDecoder().decode(ResponseBody.self, from: data)
		// TODO: Track tokens usage across project setup
		print("Usage: \(responseBody.usage)")
		return responseBody.choices.first?.message
	}
}