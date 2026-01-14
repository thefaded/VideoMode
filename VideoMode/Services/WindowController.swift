import AppKit
import Foundation

enum Browser: String, CaseIterable {
    case safari = "Safari"
    case chrome = "Google Chrome"

    var displayName: String {
        switch self {
        case .safari: return "Safari"
        case .chrome: return "Chrome"
        }
    }
}

class WindowController {
    static let shared = WindowController()

    private init() {}

    func resizeWindow(browser: Browser, preset: WindowPreset) {
        let script: String
        switch browser {
        case .safari:
            script = """
            tell application "Safari"
                if (count of windows) > 0 then
                    set bounds of front window to {\(preset.x), \(preset.y), \(preset.x + preset.width), \(preset.y + preset.height)}
                end if
            end tell
            """
        case .chrome:
            script = """
            tell application "Google Chrome"
                if (count of windows) > 0 then
                    set bounds of front window to {\(preset.x), \(preset.y), \(preset.x + preset.width), \(preset.y + preset.height)}
                end if
            end tell
            """
        }
        runAppleScript(script)
    }

    func resizeFrontmostBrowser(preset: WindowPreset) {
        if let browser = getFrontmostBrowser() {
            resizeWindow(browser: browser, preset: preset)
        }
    }

    func getCurrentWindowFrame(browser: Browser) -> (width: Int, height: Int, x: Int, y: Int)? {
        let script: String
        switch browser {
        case .safari:
            script = """
            tell application "Safari"
                if (count of windows) > 0 then
                    set windowBounds to bounds of front window
                    return windowBounds
                end if
            end tell
            """
        case .chrome:
            script = """
            tell application "Google Chrome"
                if (count of windows) > 0 then
                    set windowBounds to bounds of front window
                    return windowBounds
                end if
            end tell
            """
        }

        guard let result = runAppleScriptWithResult(script) else { return nil }

        let components = result
            .trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
            .components(separatedBy: ", ")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

        guard components.count == 4 else { return nil }

        let x = components[0]
        let y = components[1]
        let width = components[2] - x
        let height = components[3] - y

        return (width: width, height: height, x: x, y: y)
    }

    func getFrontmostBrowser() -> Browser? {
        let workspace = NSWorkspace.shared
        guard let frontmostApp = workspace.frontmostApplication else { return nil }

        switch frontmostApp.bundleIdentifier {
        case "com.apple.Safari":
            return .safari
        case "com.google.Chrome":
            return .chrome
        default:
            return nil
        }
    }

    func activateBrowser(_ browser: Browser) {
        let script = """
        tell application "\(browser.rawValue)"
            activate
        end tell
        """
        runAppleScript(script)
    }

    private func runAppleScript(_ source: String) {
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            script.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }

    private func runAppleScriptWithResult(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }

        let result = script.executeAndReturnError(&error)
        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }

        return result.stringValue
    }
}
