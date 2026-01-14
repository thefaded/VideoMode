import SwiftUI

struct PresetManagerView: View {
    @ObservedObject var presetStore: PresetStore
    @State private var selectedPreset: WindowPreset?

    var body: some View {
        HSplitView {
            // Preset list
            VStack(alignment: .leading) {
                List(selection: $selectedPreset) {
                    ForEach(Array(presetStore.presets.enumerated()), id: \.element.id) { index, preset in
                        PresetRowView(preset: preset, index: index)
                            .tag(preset)
                    }
                    .onDelete { offsets in
                        presetStore.deletePreset(at: offsets)
                    }
                    .onMove { source, destination in
                        presetStore.movePreset(from: source, to: destination)
                    }
                }
                .listStyle(.sidebar)

                HStack {
                    Button(action: addPreset) {
                        Image(systemName: "plus")
                    }
                    Button(action: deleteSelected) {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedPreset == nil)

                    Spacer()

                    Menu("Capture") {
                        ForEach(Browser.allCases, id: \.self) { browser in
                            Button("From \(browser.displayName)") {
                                captureWindow(browser: browser)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(minWidth: 220)

            // Detail view
            if let preset = selectedPreset {
                PresetDetailView(
                    preset: binding(for: preset),
                    onSave: {
                        presetStore.save()
                    }
                )
                .frame(minWidth: 320)
            } else {
                Text("Select a preset to edit")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    private func binding(for preset: WindowPreset) -> Binding<WindowPreset> {
        guard let index = presetStore.presets.firstIndex(where: { $0.id == preset.id }) else {
            return .constant(preset)
        }
        return $presetStore.presets[index]
    }

    private func addPreset() {
        let newPreset = WindowPreset(
            name: "New Preset",
            width: 1920,
            height: 1080,
            placement: .center
        )
        presetStore.addPreset(newPreset)
        selectedPreset = newPreset
    }

    private func deleteSelected() {
        if let preset = selectedPreset {
            presetStore.deletePreset(preset)
            selectedPreset = nil
        }
    }

    private func captureWindow(browser: Browser) {
        guard let frame = WindowController.shared.getCurrentWindowFrame(browser: browser) else {
            return
        }

        let newPreset = WindowPreset(
            name: "Captured \(browser.displayName)",
            width: frame.width,
            height: frame.height,
            placement: .custom,
            customX: frame.x,
            customY: frame.y
        )
        presetStore.addPreset(newPreset)
        selectedPreset = newPreset
    }
}

struct PresetRowView: View {
    let preset: WindowPreset
    let index: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(preset.name)
                    .fontWeight(.medium)
                Text("\(preset.sizeDescription) • \(preset.placementDescription)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if index < 9 {
                Text(HotkeyManager.shortcutString(for: index))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PresetDetailView: View {
    @Binding var preset: WindowPreset
    var onSave: () -> Void

    var body: some View {
        Form {
            Section("Preset Info") {
                TextField("Name", text: $preset.name)
                    .onChange(of: preset.name) { _ in onSave() }
            }

            Section("Size") {
                HStack {
                    TextField("Width", value: $preset.width, format: .number)
                        .onChange(of: preset.width) { _ in onSave() }
                    Text("x")
                    TextField("Height", value: $preset.height, format: .number)
                        .onChange(of: preset.height) { _ in onSave() }
                }

                HStack(spacing: 8) {
                    Button("1920x1080") {
                        preset.width = 1920
                        preset.height = 1080
                        onSave()
                    }
                    .buttonStyle(.bordered)

                    Button("1280x720") {
                        preset.width = 1280
                        preset.height = 720
                        onSave()
                    }
                    .buttonStyle(.bordered)

                    Button("1080x1920") {
                        preset.width = 1080
                        preset.height = 1920
                        onSave()
                    }
                    .buttonStyle(.bordered)
                }
            }

            Section("Placement") {
                Picker("Position", selection: $preset.placement) {
                    Text("Center").tag(WindowPlacement.center)
                    Divider()
                    Text("Left Half").tag(WindowPlacement.leftHalf)
                    Text("Right Half").tag(WindowPlacement.rightHalf)
                    Text("Top Half").tag(WindowPlacement.topHalf)
                    Text("Bottom Half").tag(WindowPlacement.bottomHalf)
                    Divider()
                    Text("Top Left").tag(WindowPlacement.topLeft)
                    Text("Top Right").tag(WindowPlacement.topRight)
                    Text("Bottom Left").tag(WindowPlacement.bottomLeft)
                    Text("Bottom Right").tag(WindowPlacement.bottomRight)
                    Divider()
                    Text("Almost Maximize").tag(WindowPlacement.almostMaximize)
                    Text("Custom Position").tag(WindowPlacement.custom)
                }
                .onChange(of: preset.placement) { _ in onSave() }

                if preset.placement == .custom {
                    HStack {
                        TextField("X", value: Binding(
                            get: { preset.customX ?? 0 },
                            set: { preset.customX = $0 }
                        ), format: .number)
                        .onChange(of: preset.customX) { _ in onSave() }

                        TextField("Y", value: Binding(
                            get: { preset.customY ?? 0 },
                            set: { preset.customY = $0 }
                        ), format: .number)
                        .onChange(of: preset.customY) { _ in onSave() }
                    }
                }
            }

            Section("Test") {
                HStack {
                    Button("Apply to Safari") {
                        WindowController.shared.resizeWindow(browser: .safari, preset: preset)
                    }
                    Button("Apply to Chrome") {
                        WindowController.shared.resizeWindow(browser: .chrome, preset: preset)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
