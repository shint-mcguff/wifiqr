import Foundation

enum WiFi {
    /// The SSID of the network this Mac is currently joined to, if any.
    static func currentSSID() -> String? {
        guard let device = wifiDevice(),
              let output = run("/usr/sbin/networksetup", ["-getairportnetwork", device]) else { return nil }
        // "Current Wi-Fi Network: MyNetwork" — anything else means not associated.
        let prefix = "Current Wi-Fi Network: "
        guard let line = output.split(separator: "\n").first.map(String.init),
              line.hasPrefix(prefix) else { return nil }
        return String(line.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
    }

    /// The BSD device name of the Wi-Fi interface (e.g. `en0`).
    static func wifiDevice() -> String? {
        guard let output = run("/usr/sbin/networksetup", ["-listallhardwareports"]) else { return nil }
        let lines = output.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() where line.contains("Hardware Port: Wi-Fi") {
            guard index + 1 < lines.count,
                  let range = lines[index + 1].range(of: "Device: ") else { continue }
            return String(lines[index + 1][range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    /// Looks up the saved password for `ssid` in the keychain.
    ///
    /// This triggers a keychain authorization prompt the first time — macOS
    /// guards Wi-Fi passwords behind an explicit "Allow" each session.
    static func password(for ssid: String) -> String? {
        let output = run("/usr/bin/security", ["find-generic-password", "-wa", ssid])
        let password = output?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (password?.isEmpty == false) ? password : nil
    }

    // MARK: - Helper

    private static func run(_ launchPath: String, _ args: [String]) -> String? {
        guard FileManager.default.isExecutableFile(atPath: launchPath) else { return nil }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
