import AppKit
let s: CGFloat = 1024
let img = NSImage(size: NSSize(width: s, height: s), flipped: false) { r in
    let bg = NSBezierPath(roundedRect: r.insetBy(dx: 40, dy: 40), xRadius: 225, yRadius: 225)
    NSGradient(colors: [NSColor(srgbRed: 0.17, green: 0.17, blue: 0.2, alpha: 1), NSColor(srgbRed: 0.075, green: 0.075, blue: 0.09, alpha: 1)])!.draw(in: bg, angle: -90)
    // presse-papiers
    let clip = NSBezierPath(roundedRect: NSRect(x: 262, y: 200, width: 500, height: 610), xRadius: 70, yRadius: 70)
    clip.lineWidth = 46; NSColor.white.setStroke(); clip.stroke()
    let tab = NSBezierPath(roundedRect: NSRect(x: 392, y: 760, width: 240, height: 100), xRadius: 40, yRadius: 40)
    NSColor(srgbRed: 0.96, green: 0.62, blue: 0.04, alpha: 1).setFill(); tab.fill()
    let t = NSAttributedString(string: "T", attributes: [.font: NSFont.systemFont(ofSize: 380, weight: .heavy), .foregroundColor: NSColor.white])
    let sz = t.size(); t.draw(at: NSPoint(x: (s - sz.width) / 2, y: 290))
    return true
}
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
