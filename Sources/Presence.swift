// mPASTE — icône de la barre de menus (silhouette monochrome « modèle ») et Dock en option.
// Jamais de statusItem.menu : action sur le bouton, menu ouvert sous l'icône.
import AppKit

@MainActor
final class Presence: NSObject {
    static let shared = Presence()
    private var item: NSStatusItem?

    func apply() {
        let wanted: NSApplication.ActivationPolicy = (Store.shared.showDock && !AppDelegate.isAgent) ? .regular : .accessory
        if NSApp.activationPolicy() != wanted { NSApp.setActivationPolicy(wanted) }
        if item == nil { item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength) }
        guard let b = item?.button else { return }
        b.image = Self.silhouette(); b.imagePosition = .imageOnly; b.toolTip = "mPASTE"
        item?.menu = nil
        b.target = self; b.action = #selector(clicked)
        b.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    /// Silhouette : cadre arrondi avec un « T » (texte brut), blanche et adaptée au thème de la barre.
    static func silhouette() -> NSImage {
        let img = NSImage(size: NSSize(width: 18, height: 16), flipped: false) { r in
            let box = NSBezierPath(roundedRect: r.insetBy(dx: 1.2, dy: 1.2), xRadius: 3.5, yRadius: 3.5); box.lineWidth = 1.6; NSColor.black.setStroke(); box.stroke()
            let s = NSAttributedString(string: "T", attributes: [.font: NSFont.systemFont(ofSize: 11, weight: .heavy), .foregroundColor: NSColor.black])
            let sz = s.size(); s.draw(at: NSPoint(x: (r.width - sz.width) / 2, y: (r.height - sz.height) / 2))
            return true
        }
        img.isTemplate = true
        return img
    }

    @objc private func clicked() {
        guard let button = item?.button else { return }
        makeMenu().popUp(positioning: nil, at: NSPoint(x: 0, y: button.isFlipped ? button.bounds.maxY + 4 : -4), in: button)
    }

    @objc private func open() { AppDelegate.shared?.showMain() }
    @objc private func about() { About.show() }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func toggle() { Store.shared.enabled.toggle() }

    private func makeMenu() -> NSMenu {
        let m = NSMenu()
        func add(_ t: String, _ s: Selector, key: String = "") { let i = NSMenuItem(title: t, action: s, keyEquivalent: key); i.target = self; m.addItem(i) }
        let st = Store.shared
        let head = NSMenuItem(title: st.enabled ? L.t("state.active") : L.t("state.paused"), action: nil, keyEquivalent: ""); head.isEnabled = false; m.addItem(head)
        if !st.lastAfter.isEmpty { let l = NSMenuItem(title: String(st.lastAfter.replacingOccurrences(of: "\n", with: " ").prefix(48)), action: nil, keyEquivalent: ""); l.isEnabled = false; m.addItem(l) }
        m.addItem(.separator())
        add(st.enabled ? L.t("menu.pause") : L.t("menu.resume"), #selector(toggle))
        m.addItem(.separator())
        add(L.t("menu.open"), #selector(open), key: ",")
        add(L.t("menu.about"), #selector(about))
        add(L.t("menu.quit"), #selector(quit), key: "q")
        return m
    }
}
