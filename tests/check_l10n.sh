#!/bin/zsh
# Vérifie que chaque texte de l'interface existe dans les quatre langues.
cd "$(dirname "$0")/.."
T=$(mktemp -d)
cp Sources/L10n.swift "$T/L10n.swift"
printf 'import Foundation\n' > "$T/main.swift"; printf 'if L.problems().isEmpty { print("OK : \\(L.table.count) textes × 4 langues") } else { print("Incomplet : \\(L.problems())"); exit(1) }\n' >> "$T/main.swift"
swiftc -swift-version 5 -o "$T/check" "$T/L10n.swift" "$T/main.swift" 2>&1 | grep error && exit 1
"$T/check"; rc=$?; rm -rf "$T"; exit $rc
