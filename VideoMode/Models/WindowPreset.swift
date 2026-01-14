import Foundation
import AppKit

enum WindowPlacement: String, Codable, CaseIterable {
    case center
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case leftHalf
    case rightHalf
    case topHalf
    case bottomHalf
    case almostMaximize
    case custom

    var displayName: String {
        switch self {
        case .center: return "Center"
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .leftHalf: return "Left Half"
        case .rightHalf: return "Right Half"
        case .topHalf: return "Top Half"
        case .bottomHalf: return "Bottom Half"
        case .almostMaximize: return "Almost Maximize"
        case .custom: return "Custom"
        }
    }

    func calculatePosition(windowWidth: Int, windowHeight: Int, screen: NSScreen? = nil) -> (x: Int, y: Int, width: Int, height: Int) {
        let screen = screen ?? NSScreen.main ?? NSScreen.screens.first!
        // Use full frame for total screen size, visibleFrame for usable area
        let fullFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        // AppleScript uses top-left origin (Y=0 at top, increases downward)
        // Menu bar height is the difference between full frame and visible frame at top
        let menuBarHeight = Int(fullFrame.height - visibleFrame.height - visibleFrame.origin.y + fullFrame.origin.y)
        let screenWidth = Int(visibleFrame.width)
        let screenHeight = Int(visibleFrame.height)
        let screenX = Int(visibleFrame.origin.x)

        switch self {
        case .center:
            let x = screenX + (screenWidth - windowWidth) / 2
            let y = menuBarHeight + (screenHeight - windowHeight) / 2
            return (x, y, windowWidth, windowHeight)

        case .topLeft:
            return (screenX, menuBarHeight, windowWidth, windowHeight)

        case .topRight:
            return (screenX + screenWidth - windowWidth, menuBarHeight, windowWidth, windowHeight)

        case .bottomLeft:
            return (screenX, menuBarHeight + screenHeight - windowHeight, windowWidth, windowHeight)

        case .bottomRight:
            return (screenX + screenWidth - windowWidth, menuBarHeight + screenHeight - windowHeight, windowWidth, windowHeight)

        case .leftHalf:
            return (screenX, menuBarHeight, screenWidth / 2, screenHeight)

        case .rightHalf:
            return (screenX + screenWidth / 2, menuBarHeight, screenWidth / 2, screenHeight)

        case .topHalf:
            return (screenX, menuBarHeight, screenWidth, screenHeight / 2)

        case .bottomHalf:
            return (screenX, menuBarHeight + screenHeight / 2, screenWidth, screenHeight / 2)

        case .almostMaximize:
            let padding = 20
            return (screenX + padding, menuBarHeight + padding, screenWidth - padding * 2, screenHeight - padding * 2)

        case .custom:
            // Custom uses the preset's own x/y values
            return (0, 0, windowWidth, windowHeight)
        }
    }
}

struct WindowPreset: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var width: Int
    var height: Int
    var placement: WindowPlacement
    var customX: Int?
    var customY: Int?

    init(id: UUID = UUID(), name: String, width: Int, height: Int, placement: WindowPlacement = .center, customX: Int? = nil, customY: Int? = nil) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.placement = placement
        self.customX = customX
        self.customY = customY
    }

    var sizeDescription: String {
        "\(width)x\(height)"
    }

    var placementDescription: String {
        placement.displayName
    }

    func calculateFrame(screen: NSScreen? = nil) -> (x: Int, y: Int, width: Int, height: Int) {
        if placement == .custom, let x = customX, let y = customY {
            return (x, y, width, height)
        }
        return placement.calculatePosition(windowWidth: width, windowHeight: height, screen: screen)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
