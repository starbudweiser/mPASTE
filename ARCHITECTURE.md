# mPASTE — architecture proposée (à valider avant tout code)

Décisions : design **Socle standard** · service = **agent d'arrière-plan (LaunchAgent)** · icône de barre de menus **monochrome** (modèle, `isTemplate`).

## Principe
⌘V colle toujours en texte brut, partout, sauf dans les applis exclues. ⌥⌘V colle avec la mise en forme. Appli de barre de menus (sans Dock par défaut), Swift 6 / AppKit + SwiftUI, macOS 14+.

## Modules (`Sources/`)
| Module | Rôle |
|---|---|
| `PasteInterceptor` | CGEventTap sur ⌘V / ⌥⌘V. Sur ⌘V : lit le presse-papiers, écrit une copie texte seul, laisse le collage passer, puis restaure l'original (rich) après ~150 ms. Demande l'autorisation Accessibilité. |
| `CleanerPipeline` | Chaîne de règles pures et testables : texte brut, retrait du pistage des URL (utm_*, fbclid, gclid…), espaces en trop, guillemets droits. |
| `AppRules` | Exclusions par bundle id de l'appli au premier plan (Pages, Keynote…), mode « corps seulement » pour Mail. |
| `Hotkeys` | ⌥⌘V (collage riche), ⌃⌥P (pause), réglables. |
| `ServiceInstaller` | Écrit/retire `~/Library/LaunchAgents/com.starbudweiser.mpaste.agent.plist` et appelle `launchctl bootstrap/bootout gui/<uid>`. Le même binaire se lance avec `--agent` (sans fenêtre). Statut lu via `launchctl print`. |
| `Store` | Réglages (UserDefaults) + compteur de collages ; aucune donnée de presse-papiers conservée sur disque. |
| `Presence` | Icône de barre de menus (sans `statusItem.menu` : action sur le bouton + `popUp` sous l'icône, modèle `hERALD/Presence.swift`), préférence Dock / barre / les deux. |
| `Updater` | Mise à jour automatique GitHub (modèle `mBACKUP/Updater.swift`), case « installer automatiquement » + bouton manuel. |
| `L10n` | fr / en / es / it, mêmes clés (`upd.*`, `svc.*`…), langue système, anglais par défaut. |
| `UI/` | Fenêtre principale (Aperçu, Règles, Applis, Raccourcis, Service, À propos) au design Socle ; `AboutWindow` modèle Socle ; « m » du nom en orange (#f59e0b) hors menus déroulants. |

## Flux d'un collage
1. ⌘V → `PasteInterceptor` (si non pausé et appli non exclue).
2. Presse-papiers → `CleanerPipeline` → texte nettoyé écrit seul.
3. Événement ⌘V relâché vers l'appli → collage.
4. Restauration du presse-papiers d'origine ; compteur +1 ; aperçu « avant / après » mis à jour.

## Service système
- Installer : crée le plist (RunAtLoad, KeepAlive), `bootstrap`. Désinstaller : `bootout` + suppression du plist.
- Aucune élévation de droits (agent utilisateur, pas de daemon root).
- Si l'autorisation Accessibilité manque : bandeau dans l'appli + lien vers Réglages Système.

## Build et livraison
- Deux éditions : `com.starbudweiser.mpaste.dev` (essais) et `com.starbudweiser.mpaste` (ma version locale).
- `build_all.sh mPASTE` (signature locale « sKYCRASH Local Signing », icône `.icns`), installation dans `~/Applications/Applications Personnelles`, ajout à la liste APPS.
- Hors Skyrim → collection **DESKTOP MAC TOOLKIT**. Dépôt privé `starbudweiser/mPASTE`, `release.sh` + notarisation seulement sur ta demande.
- Tests : unitaires sur `CleanerPipeline`, essais pilotés en arrière-plan.

## Points à trancher
- Le restaurateur de presse-papiers pourrait entrer en conflit avec un gestionnaire de presse-papiers : on marque la copie temporaire `org.nspasteboard.TransientType`.
- Pas de collage « riche » par défaut dans Mail : option « seulement le corps » proposée.
