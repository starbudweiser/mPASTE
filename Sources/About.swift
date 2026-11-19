// mPASTE — fenêtre « À propos » : modèle Socle (swift/AboutWindow.swift), couleurs sombres de Socle (Socle.C).
// Contenu dans l'ordre : icône 84px, nom, version, description, auteurs, licence, avertissement, origine.
import AppKit
import SwiftUI

/// Aplat de couleur dynamique (suit le thème clair/sombre), pour le fond et la barre de titre.
private final class FillView: NSView {
    var fill: NSColor { didSet { needsDisplay = true } }
    init(_ fill: NSColor) { self.fill = fill; super.init(frame: .zero) }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ dirtyRect: NSRect) { fill.setFill(); dirtyRect.fill() }
}

@MainActor
enum About {
    private static var window: NSWindow?
    private static let sideMargin: CGFloat = 28
    private static let textWidth: CGFloat = 300

    static func show() {
        if window == nil { window = makeWindow() }
        if let host = NSApp.windows.first(where: { $0 !== window && $0.isVisible && $0.canBecomeMain }), let w = window {
            let f = host.frame
            w.setFrameOrigin(NSPoint(x: f.midX - w.frame.width / 2, y: f.midY - w.frame.height / 2))
        } else { window?.center() }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    /// Essais : dessine la fenêtre dans un fichier PNG, sans l'afficher (`mPASTE --shot-about fichier.png`).
    static func snapshot(to path: String) {
        let w = makeWindow()
        NSApp.setActivationPolicy(.accessory)
        w.setFrameOrigin(NSPoint(x: -4000, y: 200))      // hors écran : rien ne passe devant le travail
        w.orderFrontRegardless()
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
        guard let v = w.contentView else { return }
        let pdf = v.dataWithPDF(inside: v.bounds)
        guard let img = NSImage(data: pdf) else { return }
        let scale: CGFloat = 2
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(v.bounds.width * scale), pixelsHigh: Int(v.bounds.height * scale), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        img.draw(in: NSRect(x: 0, y: 0, width: v.bounds.width * scale, height: v.bounds.height * scale))
        NSGraphicsContext.restoreGraphicsState()
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
    }

    private static func label(_ text: String, size: CGFloat = 12, bold: Bool = false, secondary: Bool = false) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: text)
        let paragraph = NSMutableParagraphStyle(); paragraph.alignment = .center
        let color = secondary ? NSColor(Socle.C.textMuted) : (bold ? NSColor(Socle.C.textStrong) : NSColor(Socle.C.text))
        let attr = NSMutableAttributedString(string: text, attributes: [.font: bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size), .paragraphStyle: paragraph, .foregroundColor: color])
        // Règle « Nom de l'appli » : lettre minuscule colorée
        if let r = text.range(of: "mPASTE") { attr.addAttribute(.foregroundColor, value: NSColor(brandColor), range: NSRange(r.lowerBound ..< text.index(after: r.lowerBound), in: text)) }
        field.attributedStringValue = attr
        field.alignment = .center; field.preferredMaxLayoutWidth = textWidth; field.isSelectable = false
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(lessThanOrEqualToConstant: textWidth).isActive = true
        return field
    }

    private static func makeWindow() -> NSWindow {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "?"
        let build = info["CFBundleVersion"] as? String ?? "?"
        let icon = NSImageView(image: NSApp.applicationIconImage)
        icon.imageScaling = .scaleProportionallyUpOrDown; icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 84).isActive = true; icon.heightAnchor.constraint(equalToConstant: 84).isActive = true
        let views: [NSView] = [icon, label("mPASTE", size: 17, bold: true), label(L.t("about.version", version, build), secondary: true), label(L.t("app.tagline")),
                               label("Starbudweiser & Claude Code (Anthropic)", bold: true), label(L.t("about.license")),
                               label(L.t("about.disclaimer"), secondary: true), label(L.t("about.credit"), secondary: true), label(L.t("about.collection"), secondary: true)]
        let stack = NSStackView(views: views)
        stack.orientation = .vertical; stack.alignment = .centerX; stack.spacing = 12
        stack.setCustomSpacing(6, after: views[1]); stack.setCustomSpacing(18, after: views[2])
        stack.edgeInsets = NSEdgeInsets(top: 28, left: sideMargin, bottom: 28, right: sideMargin)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.widthAnchor.constraint(equalToConstant: textWidth + 2 * sideMargin).isActive = true

        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = L.t("menu.about"); window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true; window.titleVisibility = .hidden
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.backgroundColor = NSColor(Socle.C.bg)
        let content = FillView(NSColor(Socle.C.bg))
        let bar = FillView(NSColor(Socle.C.surfaceRaised)); bar.translatesAutoresizingMaskIntoConstraints = false
        let rule = FillView(NSColor(Socle.C.border)); rule.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack); content.addSubview(bar); bar.addSubview(rule)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: content.topAnchor), bar.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: content.trailingAnchor), bar.heightAnchor.constraint(equalToConstant: 30),
            rule.leadingAnchor.constraint(equalTo: bar.leadingAnchor), rule.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            rule.bottomAnchor.constraint(equalTo: bar.bottomAnchor), rule.heightAnchor.constraint(equalToConstant: 1),
            stack.topAnchor.constraint(equalTo: bar.bottomAnchor), stack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor), stack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])
        window.contentView = content
        content.layoutSubtreeIfNeeded(); content.layoutSubtreeIfNeeded()
        window.setContentSize(content.fittingSize)
        return window
    }
}
