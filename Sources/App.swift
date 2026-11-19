// mPASTE — démarrage : fenêtre principale, instance unique, mode agent (`--agent`, sans fenêtre), À propos.
import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static var shared: AppDelegate?
    static let isAgent = CommandLine.arguments.contains("--agent")
    static let showNote = Notification.Name("fr.stephan.mpaste.show")
    var window: NSWindow?
    private var trustTimer: Timer?

    func applicationDidFinishLaunching(_ n: Notification) {
        Self.shared = self
        // Instance unique : une autre copie déjà lancée (agent ou fenêtre) reçoit la demande d'ouverture.
        let me = Bundle.main.bundleIdentifier ?? ""
        if NSRunningApplication.runningApplications(withBundleIdentifier: me).contains(where: { $0.processIdentifier != getpid() }) {
            if !Self.isAgent { DistributedNotificationCenter.default().postNotificationName(Self.showNote, object: me, userInfo: nil, deliverImmediately: true); Thread.sleep(forTimeInterval: 0.3) }
            exit(0)
        }
        DistributedNotificationCenter.default().addObserver(forName: Self.showNote, object: me, queue: .main) { _ in MainActor.assumeIsolated { self.showMain() } }
        Socle.brand("mPASTE", color: brandColor)
        Socle.apply(.system)
        NSApp.mainMenu = mainMenu()
        Presence.shared.apply()
        UpdateEngine.shared.configure(repo: "mPASTE", lang: { L.code }, brandName: "mPASTE")
        UpdateEngine.shared.autoInstall = { UserDefaults.standard.bool(forKey: "autoUpdate") }
        if !Self.isDev && !Self.isAgent { UpdateEngine.shared.start() }
        refreshTrust()
        trustTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in MainActor.assumeIsolated { self.refreshTrust() } }
        if !Self.isAgent { showMain() }
        if !PasteInterceptor.isTrusted(prompt: false) && !Self.isAgent { _ = PasteInterceptor.isTrusted(prompt: true) }
    }

    static var isDev: Bool { (Bundle.main.bundleIdentifier ?? "").hasSuffix(".dev") }

    func refreshTrust() {
        let t = PasteInterceptor.isTrusted(prompt: false)
        if Store.shared.trusted != t { Store.shared.trusted = t }
        if t { PasteInterceptor.shared.start() } else { PasteInterceptor.shared.stop() }
    }

    func showMain() {
        if window == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 620), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
            w.title = "mPASTE"; w.isReleasedWhenClosed = false; w.contentView = NSHostingView(rootView: RootView()); w.center(); w.delegate = self
            window = w
        }
        NSApp.activate(ignoringOtherApps: true); window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows f: Bool) -> Bool { showMain(); return true }

    func mainMenu() -> NSMenu {
        let main = NSMenu(); let appItem = NSMenuItem(); main.addItem(appItem); let app = NSMenu(); appItem.submenu = app
        let about = NSMenuItem(title: L.t("menu.about"), action: #selector(showAbout), keyEquivalent: ""); about.target = self; app.addItem(about)
        UpdateEngine.shared.installAppMenuItem()
        app.addItem(.separator())
        app.addItem(NSMenuItem(title: L.t("menu.quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        let editItem = NSMenuItem(); main.addItem(editItem); let edit = NSMenu(title: L.t("menu.edit")); editItem.submenu = edit
        edit.addItem(NSMenuItem(title: L.t("menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")); edit.addItem(NSMenuItem(title: L.t("menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        return main
    }
    @objc func showAbout() { About.show() }
}
