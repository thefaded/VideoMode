import Foundation
import SwiftUI

class PresetStore: ObservableObject {
    @Published var presets: [WindowPreset] = []

    private let storageKey = "VideoModePresets"

    init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WindowPreset].self, from: data) else {
            presets = defaultPresets()
            return
        }
        presets = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func addPreset(_ preset: WindowPreset) {
        presets.append(preset)
        save()
    }

    func updatePreset(_ preset: WindowPreset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
            save()
        }
    }

    func deletePreset(_ preset: WindowPreset) {
        presets.removeAll { $0.id == preset.id }
        save()
    }

    func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        save()
    }

    func movePreset(from source: IndexSet, to destination: Int) {
        presets.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func preset(at index: Int) -> WindowPreset? {
        guard index >= 0, index < presets.count else { return nil }
        return presets[index]
    }

    private func defaultPresets() -> [WindowPreset] {
        [
            WindowPreset(name: "Full HD", width: 1920, height: 1080, x: 100, y: 100),
            WindowPreset(name: "HD 720p", width: 1280, height: 720, x: 100, y: 100)
        ]
    }
}
