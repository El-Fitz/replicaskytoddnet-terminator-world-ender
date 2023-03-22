import Foundation
import ArgumentParser

struct CLITool: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "A CLI tool for managing create and build tasks.", subcommands: [Create.self, Build.self])
}

struct Create: ParsableCommand {
    enum CodingKeys: CodingKey {
        case outputDirectory
        case jsonFilePath
    }

    let errorLogger: ErrorLogger = ErrorLogger(filePath: "./errors.json", url: URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!)

    @Option(name: .shortAndLong, help: "The output directory.")
    var outputDirectory: String?

    @Option(name: .shortAndLong, help: "The path to the JSON file.")
    var jsonFilePath: String

    func runCreate() throws {
        // Implement create functionality
    }
}

struct Build: ParsableCommand {
    enum CodingKeys: CodingKey {
        case outputDirectory
        case jsonFilePath
    }

    let errorLogger: ErrorLogger = ErrorLogger(filePath: "./errors.json", url: URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!)

    @Option(name: .shortAndLong, help: "The output directory.")
    var outputDirectory: String?

    @Option(name: .shortAndLong, help: "The path to the JSON file.")
    var jsonFilePath: String
}

CLITool.main()