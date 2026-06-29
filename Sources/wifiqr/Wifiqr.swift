import ArgumentParser
import Foundation

@main
struct Wifiqr: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wifiqr",
        abstract: "Show a QR code that joins a Wi-Fi network — scan it to connect, no password typing.",
        version: "0.1.0"
    )

    @Argument(help: "Network name. Defaults to the network you're currently on.")
    var ssid: String?

    @Option(name: [.short, .long], help: "Password. If omitted, it's read from the keychain.")
    var password: String?

    @Flag(name: .long, help: "The network is open (no password).")
    var open = false

    @Flag(name: .customLong("no-qr"), help: "Print the connection string only, no QR code.")
    var noQR = false

    func run() throws {
        guard let network = ssid ?? WiFi.currentSSID(), !network.isEmpty else {
            throw RuntimeError("Couldn't determine the current Wi-Fi network. Pass one explicitly: wifiqr \"My Network\"")
        }

        let secret: String?
        if open {
            secret = nil
        } else if let password {
            secret = password
        } else {
            guard let keychain = WiFi.password(for: network) else {
                throw RuntimeError("""
                Couldn't read the password for "\(network)" from the keychain.
                Pass it directly with --password, or use --open for a passwordless network.
                """)
            }
            secret = keychain
        }

        let payload = WiFiPayload.string(ssid: network, password: secret)

        print("")
        print("  Wi-Fi: \(network)  (\(secret == nil ? "open" : "WPA/WPA2"))")
        print("")
        if !noQR, let qr = QRCode.terminalString(for: payload) {
            print(qr)
        }
        print("  \(payload)")
        print("  Scan with a phone camera to join the network.")
        print("")
    }
}

enum WiFiPayload {
    /// Builds the standard `WIFI:` URI that phone cameras understand.
    static func string(ssid: String, password: String?) -> String {
        if let password {
            return "WIFI:T:WPA;S:\(escape(ssid));P:\(escape(password));;"
        }
        return "WIFI:T:nopass;S:\(escape(ssid));;"
    }

    /// Escapes the characters reserved by the WIFI URI grammar.
    private static func escape(_ value: String) -> String {
        var result = ""
        for character in value {
            if "\\;,:\"".contains(character) { result.append("\\") }
            result.append(character)
        }
        return result
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) { self.message = message }
    var description: String { message }
}
