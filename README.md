# mPASTE

## About

**mPASTE** is a native macOS menu bar app that makes ⌘V paste as plain text everywhere. It strips formatting, removes tracking parameters from links (utm_*, fbclid, gclid…), trims extra spaces and can straighten quotes, then restores your clipboard so rich formatting is still there when you want it (⌥⌘V). It can be installed as a background agent that starts at login.

- Authors: Starbudweiser & Claude Code (Anthropic) — MIT License, © 2026 Starbudweiser.
- Provided as is, without warranty. Part of the **DESKTOP MAC TOOLKIT**. Inspired by Pure Paste (Sindre Sorhus); no code shared.
- In the app: menu **mPASTE ▸ About mPASTE**.

## Fonctions (1.0)

- **⌘V en texte brut partout** (interception par événement clavier, autorisation Accessibilité) ; le presse-papiers d'origine, mise en forme comprise, est restauré juste après. **⌥⌘V** colle avec la mise en forme, **⌃⌥P** met en pause.
- **Règles** : texte brut, retrait du pistage des liens, espaces en trop, guillemets droits.
- **Applis exclues** : Pages, Keynote, Numbers par défaut, liste modifiable.
- **Service système** : agent d'arrière-plan (LaunchAgent utilisateur, sans droits administrateur) installable et désinstallable depuis l'appli ; `mPASTE --service install|uninstall|status` en ligne de commande.
- **Interface Socle standard**, français, anglais, espagnol, italien ; mise à jour automatique ; icône de barre de menus monochrome.

## Développement

```
DEV=1 ./build_app.sh      # édition mPASTE DEV (fr.stephan.mpaste.dev)
./build_app.sh            # version locale, installée dans Applications Personnelles
mPASTE --selftest         # tests du nettoyage et du fichier de service
./release.sh 1.0.0        # notarisation et release GitHub (sur demande)
```

Voir `ARCHITECTURE.md` et `maquettes/`.
