import AppKit
import CoreGraphics
import Foundation

enum Browser: String, CaseIterable {
    case safari = "Safari"
    case chrome = "Google Chrome"
    case brave = "Brave Browser"

    var displayName: String {
        switch self {
        case .safari: return "Safari"
        case .chrome: return "Chrome"
        case .brave: return "Brave"
        }
    }
}

class WindowController {
    static let shared = WindowController()

    private init() {}

    func resizeWindow(browser: Browser, preset: WindowPreset) {
        let frame = preset.calculateFrame()
        resizeWindowToFrame(browser: browser, x: frame.x, y: frame.y, width: frame.width, height: frame.height)
        activateBrowser(browser)
    }

    func resizeFrontmostBrowser(preset: WindowPreset) {
        if let browser = getFrontmostBrowser() {
            resizeWindow(browser: browser, preset: preset)
        }
    }

    func quickPlace(browser: Browser, placement: WindowPlacement) {
        // Get current window size first
        guard let currentFrame = getCurrentWindowFrame(browser: browser) else { return }
        let frame = placement.calculatePosition(windowWidth: currentFrame.width, windowHeight: currentFrame.height)
        resizeWindowToFrame(browser: browser, x: frame.x, y: frame.y, width: frame.width, height: frame.height)
        activateBrowser(browser)
    }

    func quickPlaceFrontmostBrowser(placement: WindowPlacement) {
        // Find the most recently used browser by window order
        if let browser = getMostRecentBrowser() {
            quickPlace(browser: browser, placement: placement)
        }
    }

    private func getMostRecentBrowser() -> Browser? {
        // Get windows in front-to-back order (most recent first)
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }

        let browserBundleIds: [String: Browser] = [
            "com.apple.Safari": .safari,
            "com.google.Chrome": .chrome,
            "com.brave.Browser": .brave
        ]

        // Find the first window belonging to a supported browser
        for window in windowList {
            guard let pid = window[kCGWindowOwnerPID as String] as? Int32 else {
                continue
            }

            // Get bundle identifier from PID
            if let app = NSRunningApplication(processIdentifier: pid),
               let bundleId = app.bundleIdentifier,
               let browser = browserBundleIds[bundleId] {
                // Verify it has an open window we can control
                if getCurrentWindowFrame(browser: browser) != nil {
                    return browser
                }
            }
        }

        return nil
    }

    private func resizeWindowToFrame(browser: Browser, x: Int, y: Int, width: Int, height: Int) {
        let script = """
        tell application "\(browser.rawValue)"
            if (count of windows) > 0 then
                set bounds of front window to {\(x), \(y), \(x + width), \(y + height)}
            end if
        end tell
        """
        runAppleScript(script)
    }

    func getCurrentWindowFrame(browser: Browser) -> (width: Int, height: Int, x: Int, y: Int)? {
        let script = """
        tell application "\(browser.rawValue)"
            if (count of windows) > 0 then
                set windowBounds to bounds of front window
                return windowBounds
            end if
        end tell
        """

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
        case "com.brave.Browser":
            return .brave
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

        // For list results, stringValue is nil - need to build string from list items
        if result.numberOfItems > 0 {
            var components: [String] = []
            for i in 1...result.numberOfItems {
                if let item = result.atIndex(i) {
                    components.append(String(item.int32Value))
                }
            }
            return components.joined(separator: ", ")
        }

        return result.stringValue
    }
}
