import AppKit
import SwiftUI

/// Launches the menu bar agent. Never returns until the user quits.
enum MenuBar {
    private static var delegate: AppDelegate?

    static func run() -> Never {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let appDelegate = AppDelegate()
        delegate = appDelegate  // retain past this scope
        app.delegate = appDelegate
        app.run()
        exit(0)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "wifi", accessibilityDescription: "Wi-Fi QR")
            button.image?.isTemplate = true
            if button.image == nil { button.title = "QR" }
            button.action = #selector(togglePopover)
            button.target = self
        }
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 260, height: 320)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        // Rebuild the content each time so the QR reflects the current network.
        popover.contentViewController = NSHostingController(rootView: WiFiQRView())
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }
}

struct WiFiQRView: View {
    @State private var title = "Wi-Fi QR"
    @State private var image: NSImage?
    @State private var message: String? = "Reading Wi-Fi…"

    var body: some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 200, height: 200)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text(message ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
            }

            if image != nil {
                Text("Scan with a phone camera to join")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Refresh") { load() }
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
            .frame(width: 200)
        }
        .padding(18)
        .onAppear { load() }
    }

    private func load() {
        image = nil
        message = "Reading Wi-Fi…"
        DispatchQueue.global(qos: .userInitiated).async {
            var newTitle = "Wi-Fi QR"
            var newImage: NSImage?
            var newMessage: String?

            if let network = WiFi.currentSSID(), !network.isEmpty {
                newTitle = network
                if let password = WiFi.password(for: network) {
                    newImage = QRImage.make(for: WiFiPayload.string(ssid: network, password: password))
                } else {
                    newMessage = "Couldn't read the password from the keychain. Click Allow when prompted, then Refresh."
                }
            } else {
                newMessage = "Not connected to a Wi-Fi network."
            }

            DispatchQueue.main.async {
                title = newTitle
                image = newImage
                message = newMessage
            }
        }
    }
}
