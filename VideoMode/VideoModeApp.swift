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
            // Safari submenu
            Menu("Safari") {
                ForEach(Array(presetStore.presets.enumerated()), id: \.element.id) { index, preset in
                    Button {
                        WindowController.shared.resizeWindow(browser: .safari, preset: preset)
                    } label: {
                        Text("\(preset.name) (\(preset.sizeDescription))")
                        if index < 9 {
                            Text(HotkeyManager.shortcutString(for: index))
                        }
                    }
                }
            }

            // Chrome submenu
            Menu("Chrome") {
                ForEach(Array(presetStore.presets.enumerated()), id: \.element.id) { index, preset in
                    Button {
                        WindowController.shared.resizeWindow(browser: .chrome, preset: preset)
                    } label: {
                        Text("\(preset.name) (\(preset.sizeDescription))")
                        if index < 9 {
                            Text(HotkeyManager.shortcutString(for: index))
                        }
                    }
                }
            }

            Divider()

            // Save current window
            Menu("Save Current Window") {
                Button("From Safari") {
                    saveCurrentWindow(browser: .safari)
                }
                Button("From Chrome") {
                    saveCurrentWindow(browser: .chrome)
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
            x: frame.x,
            y: frame.y
        )

        presetStore.addPreset(preset)
        openPresetManager()
    }
}
