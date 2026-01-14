import SwiftUI

@main
struct VideoModeApp: App {
    @StateObject private var presetStore = PresetStore()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(presetStore: presetStore, openPresetManager: {
                openWindow(id: "preset-manager")
                NSApp.activate(ignoringOtherApps: true)
            })
        } label: {
            Label("VideoMode", systemImage: "aspectratio")
        }
        .menuBarExtraStyle(.menu)

        Window("Manage Presets", id: "preset-manager") {
            PresetManagerView(presetStore: presetStore)
        }
        .windowResizability(.contentSize)
    }
}

struct MenuBarContentView: View {
    @ObservedObject var presetStore: PresetStore
    var openPresetManager: () -> Void

    @State private var didSetupHotkeys = false

    var body: some View {
        Group {
            // Browser submenus
            ForEach(Browser.allCases, id: \.self) { browser in
                Menu(browser.displayName) {
                    ForEach(Array(presetStore.presets.enumerated()), id: \.element.id) { index, preset in
                        Button {
                            WindowController.shared.resizeWindow(browser: browser, preset: preset)
                        } label: {
                            Text("\(preset.name) (\(preset.sizeDescription), \(preset.placementDescription))")
                            if index < 9 {
                                Text(HotkeyManager.shortcutString(for: index))
                            }
                        }
                    }
                }
            }

            Divider()

            // Quick Place submenu
            Menu("Quick Place") {
                Button("Center") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .center)
                }

                Divider()

                Button("Left Half") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .leftHalf)
                }
                Button("Right Half") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .rightHalf)
                }
                Button("Top Half") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .topHalf)
                }
                Button("Bottom Half") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .bottomHalf)
                }

                Divider()

                Button("Top Left") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .topLeft)
                }
                Button("Top Right") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .topRight)
                }
                Button("Bottom Left") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .bottomLeft)
                }
                Button("Bottom Right") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .bottomRight)
                }

                Divider()

                Button("Almost Maximize") {
                    WindowController.shared.quickPlaceFrontmostBrowser(placement: .almostMaximize)
                }
            }

            Divider()

            // Save current window
            Menu("Save Current Window") {
                ForEach(Browser.allCases, id: \.self) { browser in
                    Button("From \(browser.displayName)") {
                        saveCurrentWindow(browser: browser)
                    }
                }
            }

            Button("Manage Presets...") {
                openPresetManager()
            }

            Divider()

            Button("Quit VideoMode") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .onAppear {
            if !didSetupHotkeys {
                HotkeyManager.shared.setup(with: presetStore)
                didSetupHotkeys = true
            }
        }
    }

    private func saveCurrentWindow(browser: Browser) {
        guard let frame = WindowController.shared.getCurrentWindowFrame(browser: browser) else {
            return
        }

        let preset = WindowPreset(
            name: "New Preset",
            width: frame.width,
            height: frame.height,
            placement: .custom,
            customX: frame.x,
            customY: frame.y
        )

        presetStore.addPreset(preset)
        openPresetManager()
    }
}
