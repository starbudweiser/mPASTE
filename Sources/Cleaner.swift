// mPASTE — nettoyage du texte collé : fonctions pures, testées par `mPASTE --selftest`.
import Foundation

struct CleanOptions: Equatable {
    var stripTracking = true
    var trimSpaces = true
    var straightQuotes = false
}

enum Cleaner {
    static let trackingExact: Set<String> = ["fbclid", "gclid", "gclsrc", "dclid", "msclkid", "yclid", "mc_cid", "mc_eid", "igshid", "_hsenc", "_hsmi", "mkt_tok", "ref_src", "twclid", "wbraid", "gbraid"]

    static func isTracking(_ name: String) -> Bool {
        let n = name.lowercased()
        return n.hasPrefix("utm_") || trackingExact.contains(n)
    }

    static func clean(_ text: String, _ o: CleanOptions) -> String {
        var s = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\u{00A0}", with: " ")
        if o.stripTracking { s = stripTracking(s) }
        if o.trimSpaces { s = trim(s) }
        if o.straightQuotes { s = straight(s) }
        return s
    }

    /// Retire les paramètres de suivi des adresses web du texte ; le reste de l'adresse est conservé tel quel.
    static func stripTracking(_ text: String) -> String {
        guard let re = try? NSRegularExpression(pattern: "https?://[^\\s<>\"')\\]]+") else { return text }
        let ns = text as NSString
        var out = "", last = 0
        for m in re.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            out += ns.substring(with: NSRange(location: last, length: m.range.location - last))
            out += cleanURL(ns.substring(with: m.range))
            last = m.range.location + m.range.length
        }
        return out + ns.substring(from: last)
    }

    static func cleanURL(_ url: String) -> String {
        guard url.contains("?"), var c = URLComponents(string: url), let items = c.queryItems else { return url }
        let kept = items.filter { !isTracking($0.name) }
        if kept.count == items.count { return url }
        c.queryItems = kept.isEmpty ? nil : kept
        return c.string ?? url
    }

    static func trim(_ text: String) -> String {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map { l -> String in
            var t = String(l)
            while let c = t.last, c == " " || c == "\t" { t.removeLast() }
            return t
        }
        var out: [String] = [], blank = 0
        for l in lines { if l.isEmpty { blank += 1; if blank <= 1 { out.append(l) } } else { blank = 0; out.append(l) } }
        lines = out
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func straight(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{2018}", with: "'").replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{201C}", with: "\"").replacingOccurrences(of: "\u{201D}", with: "\"")
    }
}
