import Foundation
import Cocoa

@objc class ThemeListener: NSObject {
    let scriptPath = ("~/.config/theme/theme-switch.sh" as NSString).expandingTildeInPath

    @objc func themeChanged(_ notification: Notification) {
        // macOS sometimes takes a moment to update the defaults, so we check both
        let appleInterfaceStyle = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        let isDark = appleInterfaceStyle == "Dark"
        let mode = isDark ? "dark" : "light"
        
        print("macOS appearance changed to \(mode). Executing sync...")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath, mode]
        
        // Pass through the user's environment variables
        process.environment = ProcessInfo.processInfo.environment
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                print("✅ Theme sync successful.")
            } else {
                print("❌ Theme sync failed with status: \(process.terminationStatus)")
            }
        } catch {
            print("❌ Failed to run theme switcher script: \(error)")
        }
    }
}

let listener = ThemeListener()

// Listen for changes
DistributedNotificationCenter.default().addObserver(
    listener,
    selector: #selector(ThemeListener.themeChanged(_:)),
    name: Notification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil
)

// Initial check on startup
listener.themeChanged(Notification(name: Notification.Name("Startup")))

print("Theme Hub Listener running. Watching for macOS appearance changes...")
RunLoop.main.run()
