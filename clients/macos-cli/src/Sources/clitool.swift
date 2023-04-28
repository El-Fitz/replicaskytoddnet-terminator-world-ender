import Foundation
import ArgumentParser

@main struct CLITool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "A CLI tool for managing create and build tasks.", subcommands: [Generate.self, Build.self, Init.self])
}

struct Init: AsyncParsableCommand {
    enum CodingKeys: CodingKey {
    }
    let errorLogger: ErrorLogger = ErrorLogger(url: URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!)
    
    var openaiApiKey: String {
        return "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"
    }

    var openaiEndpointUrl: URL {
        return URL(string: "https://api.openai.com/v1/chat/completions")!
    }
}

struct Generate: AsyncParsableCommand {
    enum CodingKeys: CodingKey {
        case outputDirectory
        case requirementsDirectory
    }

    enum GenerateError: Error {
        case failedEncodingFileTree
        case failedEncodingMessages
        case failedEncodingProjectDefinition
        case failedEncodingRequirements
        case failedGeneratingDocument(_ documentName: String)
        case failedGeneratingFileTree
        case failedGeneratingFileDefinition(filepath: String)
        case failedGeneratingFilesDefinitions
        case failedGeneratingProjectsSpecifications
        case failedGeneratingScriptsDefinitions
    }

    let errorLogger: ErrorLogger = ErrorLogger(url: URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!)
    let terminal = TerminalRepository()

    @Option(name: .shortAndLong, help: "The output directory.")
    var outputDirectory: String?

    @Option(name: .shortAndLong, help: "The path to the directory containing the requirements")
    var requirementsDirectory: String

    var openaiApiKey: String {
        return "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"
    }

    var openaiEndpointUrl: URL {
        return URL(string: "https://api.openai.com/v1/chat/completions")!
    }
}

struct Build: AsyncParsableCommand {
    enum CodingKeys: CodingKey {
        case outputDirectory
        case projectDefinitionPath
    }

    let errorLogger: ErrorLogger = ErrorLogger(url: URL(string: "https://webhook.site/a9337690-8c51-4051-8fd6-03bd90ba30fc")!)

    @Option(name: .shortAndLong, help: "The output directory.")
    var outputDirectory: String?

    @Option(name: .shortAndLong, help: "The path to the Project Definition JSON file.")
    var projectDefinitionPath: String?

    var openaiApiKey: String {
        return "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"
    }

    var openaiEndpointUrl: URL {
        return URL(string: "https://api.openai.com/v1/chat/completions")!
    }
}