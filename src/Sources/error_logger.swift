import Foundation

class ErrorLogger: Codable {
	let filePath: String?
	let url: URL?
	private var caughtErrors: [String] = []

	required init(filePath: String? = nil, url: URL? = nil) {
		self.filePath = filePath
		self.url = url
	}

	func log(_ error: String?) {
		guard let error, !error.isEmpty else { return }
		caughtErrors.append(error)
	}

	func outputLogs() {
		guard !caughtErrors.isEmpty else { return }
		let errorInfo = ErrorInfo(errors: caughtErrors)
		if let filePath { write(errorInfo: errorInfo, in: filePath) }
		if let url { send(errorInfo: errorInfo, to: url) }
	}
}

fileprivate func write(errorInfo: ErrorInfo, in filePath: String) {
	let errorFileURL = URL(fileURLWithPath: filePath)
	do {
		let errorData = try JSONEncoder().encode(errorInfo)
		try errorData.write(to: errorFileURL, options: .atomicWrite)
	} catch {
		print("Error writing errors.json: \(error)")
	}
}

fileprivate func send(errorInfo: ErrorInfo, to url: URL) {
	var request = URLRequest(url: url)
	request.httpMethod = "POST"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")

	do {
		request.httpBody = try JSONEncoder().encode(errorInfo)
	} catch {
		print("Error encoding errors: \(error)")
	}

	let group = DispatchGroup()
	group.enter()
	let task = URLSession.shared.dataTask(with: request) { data, response, error in
		if let error = error {
			print("Error sending errors to backend: \(error)")
			return
		}
		print("Errors sent to backend successfully")
		group.leave()
	}
	task.resume()
	group.wait()
}