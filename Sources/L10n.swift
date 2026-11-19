// mPASTE — textes de l'interface : une seule table, quatre langues (fr rédigé en premier, en, es, it).
import Foundation

enum L {
    enum Lang: Int { case fr = 0, en, es, it }
    static var lang: Lang = {
        let pick = ProcessInfo.processInfo.environment["MPASTE_LANG"] ?? Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "en"
        switch pick { case "fr": return .fr; case "es": return .es; case "it": return .it; default: return .en }
    }()
    static var code: String { ["fr", "en", "es", "it"][lang.rawValue] }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        guard let row = table[key] else { return key }
        let s = row[lang.rawValue]
        return args.isEmpty ? s : String(format: s, arguments: args)
    }
    static func problems() -> [String] { table.filter { $0.value.count != 4 || $0.value.contains(where: { $0.isEmpty }) }.map(\.key).sorted() }

    // [fr, en, es, it]
    static let table: [String: [String]] = [
        "app.tagline": ["Colle toujours en texte brut, partout.", "Always paste as plain text, everywhere.", "Pega siempre como texto sin formato, en todas partes.", "Incolla sempre come testo semplice, ovunque."],
        "about.version": ["Version %@ (%@)", "Version %@ (%@)", "Versión %@ (%@)", "Versione %@ (%@)"],
        "about.collection": ["Fait partie du DESKTOP MAC TOOLKIT", "Part of the DESKTOP MAC TOOLKIT", "Parte del DESKTOP MAC TOOLKIT", "Parte del DESKTOP MAC TOOLKIT"],
        "menu.about": ["À propos de mPASTE", "About mPASTE", "Acerca de mPASTE", "Informazioni su mPASTE"],
        "about.license": ["Licence MIT. © 2026 Starbudweiser.", "MIT License. © 2026 Starbudweiser.", "Licencia MIT. © 2026 Starbudweiser.", "Licenza MIT. © 2026 Starbudweiser."],
        "about.disclaimer": ["Fourni en l'état, sans garantie.", "Provided as is, without warranty.", "Se proporciona tal cual, sin garantía.", "Fornito così com'è, senza garanzia."],
        "about.credit": ["Inspiré de Pure Paste de Sindre Sorhus, sans lien avec son auteur.", "Inspired by Pure Paste by Sindre Sorhus, not affiliated with its author.", "Inspirado en Pure Paste de Sindre Sorhus, sin relación con su autor.", "Ispirato a Pure Paste di Sindre Sorhus, senza legami con il suo autore."],
        "menu.open": ["Ouvrir mPASTE…", "Open mPASTE…", "Abrir mPASTE…", "Apri mPASTE…"],
        "menu.quit": ["Quitter mPASTE", "Quit mPASTE", "Salir de mPASTE", "Esci da mPASTE"],
        "menu.pause": ["Mettre en pause", "Pause", "Pausar", "Metti in pausa"],
        "menu.resume": ["Reprendre", "Resume", "Reanudar", "Riprendi"],
        "menu.rich": ["Coller avec la mise en forme", "Paste with formatting", "Pegar con formato", "Incolla con formattazione"],
        "nav.overview": ["Aperçu", "Overview", "Resumen", "Panoramica"],
        "nav.rules": ["Règles", "Rules", "Reglas", "Regole"],
        "nav.apps": ["Applis", "Apps", "Apps", "App"],
        "nav.keys": ["Raccourcis", "Shortcuts", "Atajos", "Scorciatoie"],
        "nav.service": ["Service système", "System service", "Servicio del sistema", "Servizio di sistema"],
        "nav.about": ["À propos", "About", "Acerca de", "Informazioni"],
        "state.active": ["Collage en texte brut actif", "Plain-text paste active", "Pegado sin formato activo", "Incolla come testo semplice attivo"],
        "state.paused": ["Collage normal (en pause)", "Normal paste (paused)", "Pegado normal (en pausa)", "Incolla normale (in pausa)"],
        "state.count": ["%d collages nettoyés", "%d pastes cleaned", "%d pegados limpiados", "%d incolla puliti"],
        "ov.last": ["Dernier collage", "Last paste", "Último pegado", "Ultimo incolla"],
        "ov.before": ["Copié (avec mise en forme)", "Copied (with formatting)", "Copiado (con formato)", "Copiato (con formattazione)"],
        "ov.after": ["Collé en texte brut", "Pasted as plain text", "Pegado como texto sin formato", "Incollato come testo semplice"],
        "ov.empty": ["Rien à afficher pour l'instant : collez quelque chose avec ⌘V.", "Nothing to show yet: paste something with ⌘V.", "Nada que mostrar aún: pega algo con ⌘V.", "Niente da mostrare: incolla qualcosa con ⌘V."],
        "rules.title": ["Règles de nettoyage", "Cleaning rules", "Reglas de limpieza", "Regole di pulizia"],
        "rules.plain": ["Coller toujours en texte brut", "Always paste as plain text", "Pegar siempre como texto sin formato", "Incolla sempre come testo semplice"],
        "rules.plain.help": ["⌘V sans mise en forme", "⌘V without formatting", "⌘V sin formato", "⌘V senza formattazione"],
        "rules.tracking": ["Retirer le pistage des liens", "Remove link tracking", "Quitar el rastreo de enlaces", "Rimuovi il tracciamento dei link"],
        "rules.tracking.help": ["utm_*, fbclid, gclid…", "utm_*, fbclid, gclid…", "utm_*, fbclid, gclid…", "utm_*, fbclid, gclid…"],
        "rules.spaces": ["Supprimer les espaces en trop", "Remove extra spaces", "Quitar espacios sobrantes", "Rimuovi gli spazi in eccesso"],
        "rules.quotes": ["Guillemets droits", "Straight quotes", "Comillas rectas", "Virgolette dritte"],
        "apps.title": ["Applis où la mise en forme est conservée", "Apps that keep formatting", "Apps que conservan el formato", "App che mantengono la formattazione"],
        "apps.add": ["+ Ajouter une appli", "+ Add an app", "+ Añadir una app", "+ Aggiungi un'app"],
        "apps.add.msg": ["Choisissez l'appli à exclure du collage en texte brut", "Choose the app to exclude from plain-text paste", "Elige la app a excluir del pegado sin formato", "Scegli l'app da escludere dall'incolla come testo semplice"],
        "apps.excluded": ["Exclue", "Excluded", "Excluida", "Esclusa"],
        "apps.active": ["Active", "Active", "Activa", "Attiva"],
        "apps.remove": ["Retirer", "Remove", "Quitar", "Rimuovi"],
        "apps.footer": ["⌘V colle en texte brut partout, sauf dans les applis exclues", "⌘V pastes plain text everywhere except in excluded apps", "⌘V pega sin formato en todas partes salvo en las apps excluidas", "⌘V incolla testo semplice ovunque tranne nelle app escluse"],
        "keys.rich": ["Coller avec la mise en forme", "Paste with formatting", "Pegar con formato", "Incolla con formattazione"],
        "keys.pause": ["Mettre en pause / reprendre", "Pause / resume", "Pausar / reanudar", "Pausa / riprendi"],
        "keys.title": ["Raccourcis", "Shortcuts", "Atajos", "Scorciatoie"],
        "svc.title": ["Agent d'arrière-plan", "Background agent", "Agente en segundo plano", "Agente in background"],
        "svc.state": ["État", "Status", "Estado", "Stato"],
        "svc.running": ["● Installé et en cours", "● Installed and running", "● Instalado y en marcha", "● Installato e attivo"],
        "svc.installed": ["● Installé", "● Installed", "● Instalado", "● Installato"],
        "svc.none": ["○ Non installé", "○ Not installed", "○ No instalado", "○ Non installato"],
        "svc.install": ["Installer le service", "Install the service", "Instalar el servicio", "Installa il servizio"],
        "svc.uninstall": ["Désinstaller le service", "Uninstall the service", "Desinstalar el servicio", "Disinstalla il servizio"],
        "svc.help": ["Lancé à l'ouverture de session, sans droits administrateur.", "Starts at login, no administrator rights needed.", "Se inicia al abrir sesión, sin permisos de administrador.", "Si avvia all'accesso, senza diritti di amministratore."],
        "svc.dock": ["Afficher l'icône dans le Dock", "Show the icon in the Dock", "Mostrar el icono en el Dock", "Mostra l'icona nel Dock"],
        "svc.plist": ["Fichier installé", "Installed file", "Archivo instalado", "File installato"],
        "svc.reveal": ["Révéler le fichier", "Reveal the file", "Mostrar el archivo", "Mostra il file"],
        "svc.failed": ["L'opération a échoué.", "The operation failed.", "La operación ha fallado.", "Operazione non riuscita."],
        "perm.title": ["Autorisation", "Permission", "Permiso", "Autorizzazione"],
        "perm.name": ["Accessibilité", "Accessibility", "Accesibilidad", "Accessibilità"],
        "perm.help": ["Nécessaire pour intercepter ⌘V", "Required to intercept ⌘V", "Necesario para interceptar ⌘V", "Necessaria per intercettare ⌘V"],
        "perm.ok": ["✓ Accordée", "✓ Granted", "✓ Concedido", "✓ Concessa"],
        "perm.open": ["Ouvrir Réglages Système", "Open System Settings", "Abrir Ajustes del Sistema", "Apri Impostazioni di Sistema"],
        "upd.title": ["Mises à jour", "Updates", "Actualizaciones", "Aggiornamenti"],
        "upd.auto": ["Installer automatiquement", "Install automatically", "Instalar automáticamente", "Installa automaticamente"],
        "upd.now": ["Rechercher les mises à jour…", "Check for updates…", "Buscar actualizaciones…", "Cerca aggiornamenti…"],
    ]
}
