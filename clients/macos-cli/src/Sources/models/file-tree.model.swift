struct FileOutline: Codable {
		let filepath: String
		let outline: [String]
		let description: String
}

struct FileTree: Codable {
	let outlines: [FileOutline]
	let requirementsHash: String
}