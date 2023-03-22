import Foundation

extension Create {
  func createOutputDirectory(_ path: String) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
  }

  func readAndParseJSONFile(_ path: String) throws -> [String: Any] {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    return json
  }

  func createDefinitionsJSONFile(_ path: String, content: String) throws {
    let url = URL(fileURLWithPath: path).appendingPathComponent("definitions.json")
    try content.write(to: url, atomically: true, encoding: .utf8)
  }

  func formatJSON(json: [String: Any]) -> String {
    var formattedJSON: [String: Any] = [:]
    formattedJSON["role"] = "system"
    formattedJSON["content"] = "You are a JSON API." // Add the remaining content from the template

    if let templates = json["templates"] as? [[String: String]] {
      formattedJSON["templates"] = templates
    }

    if let requirements = json["requirements"] as? [String: Any] {
      formattedJSON["requirements"] = requirements
    }

    let jsonData = try? JSONSerialization.data(withJSONObject: formattedJSON, options: .prettyPrinted)
    return String(data: jsonData!, encoding: .utf8) ?? ""
  }

  func run() throws {
    defer { errorLogger.outputLogs() }

    let outputDir = outputDirectory ?? "./"
    try createOutputDirectory(outputDir)
    let json = try readAndParseJSONFile(jsonFilePath)
    let formattedContent = formatJSON(json: json)
    try createDefinitionsJSONFile(outputDir, content: formattedContent)
  }
}