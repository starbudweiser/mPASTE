// mPASTE — fenêtre principale au design Socle standard : barre d'état, navigation latérale, six pages.
import SwiftUI
import AppKit

enum Page: String, CaseIterable, Identifiable {
    case overview, rules, apps, keys, service
    var id: String { rawValue }
    var symbol: String { ["overview": "square.grid.2x2", "rules": "slider.horizontal.3", "apps": "app.dashed", "keys": "keyboard", "service": "gearshape"][rawValue] ?? "circle" }
    var title: String { L.t("nav.\(rawValue)") }
}

let brandColor = Color(red: 0xf5 / 255, green: 0x9e / 255, blue: 0x0b / 255)

struct RootView: View {
    @ObservedObject var store = Store.shared
    @State private var page: Page = .overview
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(Socle.C.border)
            HStack(spacing: 0) {
                sidebar
                Divider().overlay(Socle.C.border)
                ScrollView { content.padding(18).frame(maxWidth: .infinity, alignment: .topLeading) }
            }
        }
        .background(Socle.C.bg).foregroundStyle(Socle.C.text)
        .frame(minWidth: 860, minHeight: 580)
    }

    var header: some View {
        HStack(spacing: 10) {
            Text(branded: "mPASTE").socle(Socle.T.title).foregroundStyle(Socle.C.textStrong)
            Spacer()
            Circle().fill(store.enabled ? Socle.C.success : Socle.C.warning).frame(width: 8, height: 8)
            Text(store.enabled ? L.t("state.active") : L.t("state.paused")).socle(Socle.T.body).foregroundStyle(Socle.C.textMuted)
            Text("·").foregroundStyle(Socle.C.textSubtle)
            Text(L.t("state.count", store.count)).socle(Socle.T.labelStrong)
            Button(store.enabled ? L.t("menu.pause") : L.t("menu.resume")) { store.enabled.toggle() }.buttonStyle(SocleButtonStyle(.secondary, height: 28))
        }.padding(.horizontal, 16).frame(height: 46).background(Socle.C.surfaceRaised)
    }

    var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Page.allCases) { p in
                Button { page = p } label: {
                    HStack(spacing: 9) { Image(systemName: p.symbol).frame(width: 18); Text(p.title).socle(page == p ? Socle.T.labelStrong : Socle.T.body); Spacer() }
                        .padding(.horizontal, 10).frame(height: 32).contentShape(Rectangle())
                        .background(page == p ? Socle.C.surfaceSelected : .clear, in: RoundedRectangle(cornerRadius: 4))
                        .foregroundStyle(page == p ? Socle.C.textStrong : Socle.C.textMuted)
                }.buttonStyle(.plain)
            }
            Button { About.show() } label: {
                HStack(spacing: 9) { Image(systemName: "info.circle").frame(width: 18); Text(L.t("nav.about")).socle(Socle.T.body); Spacer() }
                    .padding(.horizontal, 10).frame(height: 32).contentShape(Rectangle()).foregroundStyle(Socle.C.textMuted)
            }.buttonStyle(.plain)
            Spacer()
            Text("DESKTOP MAC TOOLKIT").socle(Socle.T.caption).foregroundStyle(Socle.C.textSubtle).padding(.horizontal, 10)
            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")").socle(Socle.T.caption).foregroundStyle(Socle.C.textSubtle).padding(.horizontal, 10)
        }.padding(10).frame(width: 210).background(Socle.C.surfaceRaised)
    }

    @ViewBuilder var content: some View {
        switch page {
        case .overview: OverviewPage()
        case .rules: RulesPage()
        case .apps: AppsPage()
        case .keys: KeysPage()
        case .service: ServicePage()
        }
    }
}

// MARK: - Composants

struct Card<C: View>: View {
    let title: String; @ViewBuilder let content: C
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased()).socle(Socle.T.eyebrow).foregroundStyle(Socle.C.textMuted)
            VStack(alignment: .leading, spacing: 0) { content }.padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Socle.C.surface, in: RoundedRectangle(cornerRadius: 6)).overlay(RoundedRectangle(cornerRadius: 6).stroke(Socle.C.border))
        }
    }
}

struct SwitchRow: View {
    let title: String; var help: String? = nil; @Binding var on: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) { Text(title).socle(Socle.T.body); if let help { Text(help).socle(Socle.T.meta).foregroundStyle(Socle.C.textMuted) } }
            Spacer(); Toggle("", isOn: $on).toggleStyle(.switch).labelsHidden()
        }.padding(.vertical, 6)
    }
}

struct Tag: View {
    let text: String; var tone: Color = Socle.C.textMuted
    var body: some View { Text(text).socle(Socle.T.caption).fontWeight(.semibold).foregroundStyle(tone).padding(.horizontal, 8).padding(.vertical, 2).background(tone.opacity(0.18), in: RoundedRectangle(cornerRadius: 4)) }
}

// MARK: - Pages

struct OverviewPage: View {
    @ObservedObject var store = Store.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !store.trusted { PermissionCard() }
            Card(title: L.t("ov.last")) {
                if store.lastBefore.isEmpty { Text(L.t("ov.empty")).socle(Socle.T.body).foregroundStyle(Socle.C.textMuted).padding(.vertical, 8) }
                else {
                    HStack(alignment: .top, spacing: 10) {
                        clip(L.t("ov.before"), store.lastBefore, after: false)
                        Image(systemName: "arrow.right").foregroundStyle(Socle.C.textMuted).padding(.top, 40)
                        clip(L.t("ov.after"), store.lastAfter, after: true)
                    }
                }
            }
            RulesCard()
        }
    }
    func clip(_ title: String, _ text: String, after: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).socle(Socle.T.label).foregroundStyle(Socle.C.textMuted)
            Text(String(text.prefix(400))).socle(Socle.T.mono).textSelection(.enabled).frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                .padding(10).background(Socle.C.bgInset, in: RoundedRectangle(cornerRadius: 4)).overlay(RoundedRectangle(cornerRadius: 4).stroke(after ? Socle.C.accent : .clear, lineWidth: 2))
        }.frame(maxWidth: .infinity)
    }
}

struct RulesCard: View {
    @ObservedObject var store = Store.shared
    var body: some View {
        Card(title: L.t("rules.title")) {
            SwitchRow(title: L.t("rules.plain"), help: L.t("rules.plain.help"), on: $store.plain)
            Divider().overlay(Socle.C.border)
            SwitchRow(title: L.t("rules.tracking"), help: L.t("rules.tracking.help"), on: $store.stripTracking)
            Divider().overlay(Socle.C.border)
            SwitchRow(title: L.t("rules.spaces"), on: $store.trimSpaces)
            Divider().overlay(Socle.C.border)
            SwitchRow(title: L.t("rules.quotes"), on: $store.straightQuotes)
        }
    }
}
struct RulesPage: View { var body: some View { RulesCard() } }

struct PermissionCard: View {
    @ObservedObject var store = Store.shared
    var body: some View {
        Card(title: L.t("perm.title")) {
            HStack {
                VStack(alignment: .leading, spacing: 1) { Text(L.t("perm.name")).socle(Socle.T.body); Text(L.t("perm.help")).socle(Socle.T.meta).foregroundStyle(Socle.C.textMuted) }
                Spacer()
                if store.trusted { Tag(text: L.t("perm.ok"), tone: Socle.C.success) }
                else { Button(L.t("perm.open")) { _ = PasteInterceptor.isTrusted(prompt: true); NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!) }.buttonStyle(SocleButtonStyle(.primary, height: 28)) }
            }.padding(.vertical, 4)
        }
    }
}

struct AppsPage: View {
    @ObservedObject var store = Store.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Card(title: L.t("apps.title")) {
                ForEach($store.apps) { $a in
                    HStack(spacing: 10) {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: a.id) { Image(nsImage: NSWorkspace.shared.icon(forFile: url.path)).resizable().frame(width: 22, height: 22) }
                        else { Image(systemName: "app").frame(width: 22, height: 22) }
                        Text(a.name).socle(Socle.T.body)
                        Spacer()
                        Button { a.excluded.toggle() } label: { Tag(text: a.excluded ? L.t("apps.excluded") : L.t("apps.active"), tone: a.excluded ? Socle.C.textMuted : Socle.C.success) }.buttonStyle(.plain)
                        Button(L.t("apps.remove")) { store.apps.removeAll { $0.id == a.id } }.buttonStyle(SocleButtonStyle(.tertiary, height: 24))
                    }.padding(.vertical, 5)
                    Divider().overlay(Socle.C.border)
                }
                Button(L.t("apps.add")) { addApp() }.buttonStyle(SocleButtonStyle(.secondary, height: 28)).padding(.top, 8)
            }
            Text(L.t("apps.footer")).socle(Socle.T.meta).foregroundStyle(Socle.C.textMuted)
        }
    }
    func addApp() {
        let p = NSOpenPanel(); p.allowedContentTypes = [.application]; p.directoryURL = URL(fileURLWithPath: "/Applications"); p.message = L.t("apps.add.msg")
        guard p.runModal() == .OK, let u = p.url, let b = Bundle(url: u), let id = b.bundleIdentifier else { return }
        let name = (b.infoDictionary?["CFBundleDisplayName"] as? String) ?? (b.infoDictionary?["CFBundleName"] as? String) ?? u.deletingPathExtension().lastPathComponent
        if !store.apps.contains(where: { $0.id == id }) { store.apps.append(ExcludedApp(id: id, name: name, excluded: true)) }
    }
}

struct KeysPage: View {
    var body: some View {
        Card(title: L.t("keys.title")) {
            row(L.t("keys.rich"), ["⌥", "⌘", "V"]); Divider().overlay(Socle.C.border)
            row(L.t("keys.pause"), ["⌃", "⌥", "P"])
        }
    }
    func row(_ t: String, _ keys: [String]) -> some View {
        HStack { Text(t).socle(Socle.T.body); Spacer(); HStack(spacing: 4) { ForEach(keys, id: \.self) { SocleKeycap(symbol: $0) } } }.padding(.vertical, 6)
    }
}

struct ServicePage: View {
    @ObservedObject var store = Store.shared
    @State private var installed = ServiceInstaller.isInstalled
    @State private var loaded = ServiceInstaller.isLoaded
    @State private var failed = false
    @State private var busy = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Card(title: L.t("svc.title")) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) { Text(L.t("svc.state")).socle(Socle.T.body); Text(ServiceInstaller.label).socle(Socle.T.meta).foregroundStyle(Socle.C.textMuted) }
                    Spacer()
                    Tag(text: installed ? (loaded ? L.t("svc.running") : L.t("svc.installed")) : L.t("svc.none"), tone: installed ? Socle.C.success : Socle.C.warning)
                }.padding(.vertical, 6)
                Text(L.t("svc.help")).socle(Socle.T.meta).foregroundStyle(Socle.C.textMuted).padding(.bottom, 6)
                Divider().overlay(Socle.C.border)
                SwitchRow(title: L.t("svc.dock"), on: $store.showDock)
                Divider().overlay(Socle.C.border)
                HStack {
                    Button(installed ? L.t("svc.uninstall") : L.t("svc.install")) {
                        guard !busy else { return }
                        busy = true; failed = false
                        let wasInstalled = installed
                        DispatchQueue.global().async {
                            let ok = wasInstalled ? ServiceInstaller.uninstall() : ServiceInstaller.install()
                            DispatchQueue.main.async { failed = !ok; busy = false; refresh() }
                        }
                    }.buttonStyle(SocleButtonStyle(installed ? .secondary : .primary, height: 28)).disabled(busy)
                    if installed { Button(L.t("svc.reveal")) { NSWorkspace.shared.activateFileViewerSelecting([ServiceInstaller.plistURL]) }.buttonStyle(SocleButtonStyle(.secondary, height: 28)) }
                    if failed { Text(ServiceInstaller.lastError.isEmpty ? L.t("svc.failed") : "\(L.t("svc.failed")) \(ServiceInstaller.lastError)").socle(Socle.T.meta).foregroundStyle(Socle.C.danger).lineLimit(3) }
                }.padding(.top, 8)
            }
            if installed { Card(title: L.t("svc.plist")) { Text(ServiceInstaller.plistURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")).socle(Socle.T.monoSm).textSelection(.enabled).padding(6) } }
            PermissionCard()
            Card(title: L.t("upd.title")) {
                SwitchRow(title: L.t("upd.auto"), on: $store.autoUpdate)
                Divider().overlay(Socle.C.border)
                Button(L.t("upd.now")) { UpdateEngine.shared.checkNow() }.buttonStyle(SocleButtonStyle(.secondary, height: 28)).padding(.top, 8)
            }
        }.onAppear(perform: refresh)
    }
    func refresh() { installed = ServiceInstaller.isInstalled; loaded = ServiceInstaller.isLoaded }
}
