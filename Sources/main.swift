import AppKit

// `mPASTE --check-l10n` : chaque texte existe dans les quatre langues.
if CommandLine.arguments.contains("--check-l10n") {
    let p = L.problems()
    if p.isEmpty { print("OK : \(L.table.count) textes × 4 langues"); exit(0) }
    print("Textes incomplets : \(p.joined(separator: ", "))"); exit(1)
}
// `mPASTE --selftest` : nettoyage du texte et fichier du service (sans fenêtre).
if CommandLine.arguments.contains("--selftest") { exit(SelfTest.run()) }

// `mPASTE --service install|uninstall|status` : pilote le service depuis le terminal (essais, scripts).
if let i = CommandLine.arguments.firstIndex(of: "--service"), i + 1 < CommandLine.arguments.count {
    switch CommandLine.arguments[i + 1] {
    case "install": print(ServiceInstaller.install() ? "installé" : "échec"); 
    case "uninstall": print(ServiceInstaller.uninstall() ? "désinstallé" : "échec")
    default: print("installé=\(ServiceInstaller.isInstalled) chargé=\(ServiceInstaller.isLoaded)")
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = MainActor.assumeIsolated { AppDelegate() }
app.delegate = delegate
app.setActivationPolicy(CommandLine.arguments.contains("--agent") ? .accessory : .regular)
app.run()
