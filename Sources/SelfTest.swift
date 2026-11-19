import Foundation

enum SelfTest {
    static func run() -> Int32 {
        var fails = 0
        func check(_ name: String, _ ok: Bool) { print((ok ? "OK  " : "ÉCHEC  ") + name); if !ok { fails += 1 } }
        let o = CleanOptions()
        check("pistage retiré", Cleaner.clean("voir https://mon-site.fr/?utm_source=mail&fbclid=A9x", o) == "voir https://mon-site.fr/")
        check("paramètre utile gardé", Cleaner.clean("https://x.fr/p?id=3&utm_medium=a", o) == "https://x.fr/p?id=3")
        check("adresse sans pistage intacte", Cleaner.clean("https://x.fr/p?id=3", o) == "https://x.fr/p?id=3")
        check("espaces en trop", Cleaner.clean("a  \n\n\n\nb \n", o) == "a\n\nb")
        check("guillemets droits", Cleaner.clean("“a” l’ami", CleanOptions(stripTracking: false, trimSpaces: false, straightQuotes: true)) == "\"a\" l'ami")
        check("options coupées", Cleaner.clean("https://x.fr/?utm_source=a  ", CleanOptions(stripTracking: false, trimSpaces: false, straightQuotes: false)) == "https://x.fr/?utm_source=a  ")
        let plist = ServiceInstaller.plistContents(executable: "/Applications/mPASTE.app/Contents/MacOS/mPASTE")
        check("plist du service", plist.contains("--agent") && plist.contains("RunAtLoad") && plist.contains("<key>Label</key>"))
        check("plist valide", (try? PropertyListSerialization.propertyList(from: Data(plist.utf8), options: [], format: nil)) != nil)
        check("textes complets", L.problems().isEmpty)
        return fails == 0 ? 0 : 1
    }
}
