struct FileDefinition: Codable {
	let filepath: String
	let content: String?

	func contentToWrite(fileTreeOutlineGetter: (_ filepath: String) -> [String]?) -> String {
		if let content {
			return content
		}
		return content ?? """
		// Failed to generate content for file: \(filepath)
		/**
			* File Outline:
			* \(fileTreeOutlineGetter(filepath) ?? ["No outline provided"])
			*/
		"""
	}
}