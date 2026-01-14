import AppKit
import Carbon

class HotkeyManager {
    static let shared = HotkeyManager()

    private var hotKeyRefs: [EventHotKeyRef?] = Array(repeating: nil, count: 9)
    private var presetStore: PresetStore?

    private init() {}

    func setup(with store: PresetStore) {
        self.presetStore = store
        registerHotkeys()
    }

    func registerHotkeys() {
        unregisterAll()

        // Key codes for 1-9
        let keyCodes: [UInt32] = [18, 19, 20, 21, 23, 22, 26, 28, 25] // 1-9 on keyboard

        for i in 0..<9 {
            var hotKeyRef: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: OSType(0x564D_4F44), id: UInt32(i)) // "VMOD"
            let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

            let status = RegisterEventHotKey(
                keyCodes[i],
                modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            if status == noErr {
                hotKeyRefs[i] = hotKeyRef
            }
        }

        installEventHandler()
    }

    private var eventHandler: EventHandlerRef?

    private func installEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            let index = Int(hotKeyID.id)
            HotkeyManager.shared.handleHotkey(index: index)
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandler
        )
    }

    func handleHotkey(index: Int) {
        guard let preset = presetStore?.preset(at: index) else { return }
        WindowController.shared.resizeFrontmostBrowser(preset: preset)
    }

    func unregisterAll() {
        for i in 0..<hotKeyRefs.count {
            if let ref = hotKeyRefs[i] {
                UnregisterEventHotKey(ref)
                hotKeyRefs[i] = nil
            }
        }
    }

    deinit {
        unregisterAll()
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }

    static func shortcutString(for index: Int) -> String {
        guard index >= 0, index < 9 else { return "" }
        return "\u{21E7}\u{2318}\(index + 1)"
    }
}
