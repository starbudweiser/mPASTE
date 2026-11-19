// mPASTE — intercepte ⌘V : écrit une copie en texte brut nettoyé dans le presse-papiers, laisse le collage passer,
// puis restaure le presse-papiers d'origine (mise en forme comprise). ⌥⌘V passe sans changement (collage avec mise en forme).
// Nécessite l'autorisation Accessibilité.
import AppKit
import ApplicationServices

@MainActor
final class PasteInterceptor {
    static let shared = PasteInterceptor()
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private let transient = NSPasteboard.PasteboardType("org.nspasteboard.TransientType")
    private let richTypes: [NSPasteboard.PasteboardType] = [.rtf, .rtfd, .html, .tiff, .png, .pdf, NSPasteboard.PasteboardType("public.url")]

    static func isTrusted(prompt: Bool) -> Bool {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    @discardableResult
    func start() -> Bool {
        if tap != nil { return true }
        guard Self.isTrusted(prompt: false) else { return false }
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let cb: CGEventTapCallBack = { _, type, event, _ in
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                DispatchQueue.main.async { PasteInterceptor.shared.reenable() }
                return Unmanaged.passUnretained(event)
            }
            guard type == .keyDown else { return Unmanaged.passUnretained(event) }
            let code = event.getIntegerValueField(.keyboardEventKeycode)
            let f = event.flags
            let cmd = f.contains(.maskCommand), opt = f.contains(.maskAlternate), ctl = f.contains(.maskControl), shift = f.contains(.maskShift)
            if code == 9, cmd, !opt, !ctl, !shift {                 // ⌘V
                // Le tap tourne sur le fil principal : accès direct, sans attente.
                MainActor.assumeIsolated { PasteInterceptor.shared.handlePaste() }
            } else if code == 35, ctl, opt, !cmd, !shift {         // ⌃⌥P : pause / reprise
                DispatchQueue.main.async { Store.shared.enabled.toggle() }
                return nil
            }
            return Unmanaged.passUnretained(event)
        }
        guard let t = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: cb, userInfo: nil) else { return false }
        tap = t
        source = CFMachPortCreateRunLoopSource(nil, t, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: t, enable: true)
        return true
    }

    func stop() {
        if let s = source { CFRunLoopRemoveSource(CFRunLoopGetMain(), s, .commonModes) }
        if let t = tap { CGEvent.tapEnable(tap: t, enable: false) }
        tap = nil; source = nil
    }

    private func reenable() { if let t = tap { CGEvent.tapEnable(tap: t, enable: true) } }

    private func handlePaste() {
        let store = Store.shared
        guard store.enabled, store.plain else { return }
        if store.isExcluded(NSWorkspace.shared.frontmostApplication?.bundleIdentifier) { return }
        let pb = NSPasteboard.general
        guard let items = pb.pasteboardItems, !items.isEmpty else { return }
        let original: String
        if let s = pb.string(forType: .string) { original = s }
        else if let rtf = pb.data(forType: .rtf), let a = NSAttributedString(rtf: rtf, documentAttributes: nil) { original = a.string }
        else if let html = pb.data(forType: .html), let a = try? NSAttributedString(data: html, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) { original = a.string }
        else { return }
        let cleaned = Cleaner.clean(original, store.options)
        let hasRich = items.contains { $0.types.contains { richTypes.contains($0) } || $0.types.count > 2 }
        if !hasRich && cleaned == original { return }
        // Copie de l'état d'origine, puis texte brut seul
        let saved: [[(NSPasteboard.PasteboardType, Data)]] = items.map { it in it.types.compactMap { t in it.data(forType: t).map { (t, $0) } } }
        pb.clearContents()
        pb.setString(cleaned, forType: .string)
        pb.setData(Data(), forType: transient)
        let ours = pb.changeCount
        store.lastBefore = original; store.lastAfter = cleaned; store.count += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            let pb = NSPasteboard.general
            guard pb.changeCount == ours else { return }            // quelqu'un a copié entre-temps : ne rien écraser
            pb.clearContents()
            let restored: [NSPasteboardItem] = saved.map { types in let i = NSPasteboardItem(); for (t, d) in types { i.setData(d, forType: t) }; return i }
            pb.writeObjects(restored)
        }
    }
}
