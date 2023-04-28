import Foundation

class TerminalRepository {
	private var displayingLoader = false
	private let loaderChars = ["|", "/", "-", "\\"]
	

	func moveCursorUp(lines: Int) {
    print("\u{1B}[\(lines)A", terminator: "")
	}

	func clearLine() {
    print("\u{1B}[2K", terminator: "")
	}

	func clearPreviousLines(lines: Int) {
		for _ in 0..<lines {
			moveCursorUp(lines: 1)
			clearLine()
		}
	}

	func startLoader() {
		guard !displayingLoader else {
			return
		}
		displayingLoader = true

		var currentIndex = 0
		DispatchQueue.global().async {
				while self.displayingLoader {
						let char = self.loaderChars[currentIndex]
						print("\r\(char)", terminator: "")
						fflush(stdout)
						currentIndex = (currentIndex + 1) % self.loaderChars.count
						usleep(200000) // Adjust the speed of the loader by modifying this value
				}
		}
	}
	
	func stopLoader() {
		displayingLoader = false
		print("\r ", terminator: "") // Clear the loader character
		fflush(stdout)
	}

	func startTextTimerLoader(_ text: String, inline: Bool = false) {
		guard !displayingLoader else {
			return
		}
		displayingLoader = true
		if inline {
      print("\u{001B}[2K\r", terminator: "")
    }

		let startTime = Date()
		DispatchQueue.global().async {
			while self.displayingLoader {
				let elapsedSeconds = Date().timeIntervalSince(startTime)
				self.clearLine()
				print("\r\(text) (\(Int(elapsedSeconds))s)", terminator: "")
				fflush(stdout)
				usleep(100000)
			}
		}
	}

	func stopTextTimerLoader() {
		displayingLoader = false
		print("\r ", terminator: "") // Clear the loader character
		fflush(stdout)
	}

  func printText(_ text: String, inline: Bool = false) {
    if inline {
      print("\u{001B}[2K\r", terminator: "")
    }
    print(text)
  }
  
  func clearScreen() {
    print("\u{001B}[2J")
  }
  
  func promptForInput(withMessage message: String, required: Bool = false, multiline: Bool = false, inline: Bool = false) -> String? {
    if inline {
      print("\u{001B}[2K\r", terminator: "")
    }
    print(message, terminator: "")
    var input: String?
    if multiline {
      var lines: [String] = []
      repeat {
        if let line = readLine() {
          if line.isEmpty {
            break
          }
          lines.append(line)
        }
      } while true
      input = lines.joined(separator: "\n")
    } else {
      input = readLine()
    }
    
    if required && input == nil {
      print("Error: input required")
      return nil
    }
    
    return input
  }
}