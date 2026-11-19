// mPASTE — service système : agent d'arrière-plan (LaunchAgent utilisateur, sans droits administrateur).
// Le même binaire se lance avec `--agent` à l'ouverture de session. Écrit/retire ~/Library/LaunchAgents/<id>.agent.plist.
import Foundation

enum ServiceInstaller {
    static var bundleID: String { Bundle.main.bundleIdentifier ?? "fr.stephan.mpaste" }
    static var label: String { bundleID + ".agent" }
    static var plistURL: URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents/\(label).plist") }
    static var uid: String { String(getuid()) }

    static var isInstalled: Bool { FileManager.default.fileExists(atPath: plistURL.path) }
    static var isLoaded: Bool { run("/bin/launchctl", ["print", "gui/\(uid)/\(label)"]).status == 0 }

    static func plistContents(executable: String) -> String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        \t<key>Label</key><string>\(label)</string>
        \t<key>ProgramArguments</key><array><string>\(executable)</string><string>--agent</string></array>
        \t<key>RunAtLoad</key><true/>
        \t<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
        \t<key>ProcessType</key><string>Interactive</string>
        </dict></plist>
        """
    }

    /// Dernier message d'erreur de launchctl (affiché dans l'interface quand l'installation échoue).
    nonisolated(unsafe) static var lastError = ""

    @discardableResult
    static func install() -> Bool {
        lastError = ""
        guard let exe = Bundle.main.executablePath else { lastError = "executable"; return false }
        let dir = plistURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try plistContents(executable: exe).write(to: plistURL, atomically: true, encoding: .utf8)
        } catch { lastError = error.localizedDescription; return false }
        if isLoaded { _ = run("/bin/launchctl", ["bootout", "gui/\(uid)/\(label)"]); Thread.sleep(forTimeInterval: 0.6) }
        _ = run("/bin/launchctl", ["enable", "gui/\(uid)/\(label)"])
        // bootstrap peut échouer (erreur 5) juste après un bootout ou un lancement : on réessaie, puis repli sur `load`.
        for attempt in 0..<4 {
            let r = run("/bin/launchctl", ["bootstrap", "gui/\(uid)", plistURL.path])
            if r.status == 0 || isLoaded { return true }
            lastError = r.out.trimmingCharacters(in: .whitespacesAndNewlines)
            Thread.sleep(forTimeInterval: 0.5 * Double(attempt + 1))
        }
        let r = run("/bin/launchctl", ["load", "-w", plistURL.path])
        if r.status == 0 || isLoaded { return true }
        if !r.out.isEmpty { lastError = r.out.trimmingCharacters(in: .whitespacesAndNewlines) }
        return false
    }

    @discardableResult
    static func uninstall() -> Bool {
        _ = run("/bin/launchctl", ["bootout", "gui/\(uid)/\(label)"])
        try? FileManager.default.removeItem(at: plistURL)
        return !isInstalled
    }

    @discardableResult
    static func run(_ path: String, _ args: [String]) -> (status: Int32, out: String) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: path); p.arguments = args
        let pipe = Pipe(); p.standardOutput = pipe; p.standardError = pipe
        do { try p.run() } catch { return (-1, "") }
        let data = pipe.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        return (p.terminationStatus, String(data: data, encoding: .utf8) ?? "")
    }
}
