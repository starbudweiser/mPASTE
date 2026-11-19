// mPASTE — réglages et état partagé (UserDefaults). Aucun contenu de presse-papiers n'est écrit sur disque.
import Foundation
import SwiftUI

struct ExcludedApp: Codable, Identifiable, Equatable { var id: String; var name: String; var excluded: Bool }

@MainActor
final class Store: ObservableObject {
    static let shared = Store()
    private let d = UserDefaults.standard

    @Published var enabled: Bool { didSet { d.set(enabled, forKey: "enabled") } }
    @Published var plain: Bool { didSet { d.set(plain, forKey: "plain") } }
    @Published var stripTracking: Bool { didSet { d.set(stripTracking, forKey: "stripTracking") } }
    @Published var trimSpaces: Bool { didSet { d.set(trimSpaces, forKey: "trimSpaces") } }
    @Published var straightQuotes: Bool { didSet { d.set(straightQuotes, forKey: "straightQuotes") } }
    @Published var showDock: Bool { didSet { d.set(showDock, forKey: "showDock"); Presence.shared.apply() } }
    @Published var autoUpdate: Bool { didSet { d.set(autoUpdate, forKey: "autoUpdate") } }
    @Published var apps: [ExcludedApp] { didSet { d.set(try? JSONEncoder().encode(apps), forKey: "apps") } }
    @Published var count: Int { didSet { d.set(count, forKey: "count") } }
    @Published var lastBefore: String = ""
    @Published var lastAfter: String = ""
    @Published var trusted = false

    init() {
        let d = UserDefaults.standard
        d.register(defaults: ["enabled": true, "plain": true, "stripTracking": true, "trimSpaces": true, "straightQuotes": false, "showDock": false, "autoUpdate": false])
        enabled = d.bool(forKey: "enabled"); plain = d.bool(forKey: "plain")
        stripTracking = d.bool(forKey: "stripTracking"); trimSpaces = d.bool(forKey: "trimSpaces"); straightQuotes = d.bool(forKey: "straightQuotes")
        showDock = d.bool(forKey: "showDock"); autoUpdate = d.bool(forKey: "autoUpdate"); count = d.integer(forKey: "count")
        if let data = d.data(forKey: "apps"), let a = try? JSONDecoder().decode([ExcludedApp].self, from: data) { apps = a }
        else { apps = [ExcludedApp(id: "com.apple.iWork.Pages", name: "Pages", excluded: true), ExcludedApp(id: "com.apple.iWork.Keynote", name: "Keynote", excluded: true), ExcludedApp(id: "com.apple.iWork.Numbers", name: "Numbers", excluded: true)] }
    }

    var options: CleanOptions { CleanOptions(stripTracking: stripTracking, trimSpaces: trimSpaces, straightQuotes: straightQuotes) }
    func isExcluded(_ bundleID: String?) -> Bool { apps.contains { $0.id == bundleID && $0.excluded } }
}
