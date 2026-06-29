# wifiqr

Show a QR code for your Wi-Fi network so guests can join by pointing their camera at your screen — no spelling out passwords.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

```console
$ wifiqr

  Wi-Fi: HomeNetwork  (WPA/WPA2)

  █▀▀▀▀▀█ ▀▄█ █▀▀▀▀▀█
  █ ███ █ █▀▄ █ ███ █     (a real, scannable QR renders here)
  █ ▀▀▀ █ ▀█▀ █ ▀▀▀ █
  ▀▀▀▀▀▀▀ █▄█ ▀▀▀▀▀▀▀

  WIFI:T:WPA;S:HomeNetwork;P:hunter2;;
  Scan with a phone camera to join the network.
```

## Why

"What's the Wi-Fi password?" — answered once, on screen, scannable. iOS and Android cameras both recognize the `WIFI:` QR format and offer to join with one tap.

## Install

### Homebrew

```sh
brew install shint-mcguff/tap/wifiqr
```

### From source

```sh
git clone https://github.com/shint-mcguff/wifiqr
cd wifiqr
swift build -c release
cp .build/release/wifiqr /usr/local/bin/
```

## Usage

```sh
wifiqr                          # QR for the network you're currently on
wifiqr "Cafe Guest"             # QR for a saved network by name
wifiqr "Cafe Guest" -p latte    # supply the password directly (no keychain)
wifiqr "Open Hotspot" --open    # passwordless network
wifiqr --no-qr                  # print just the WIFI: connection string
```

When you don't pass `--password`, `wifiqr` reads the saved password from your
keychain. macOS guards Wi-Fi passwords, so the first lookup each session shows a
**keychain authorization prompt** — click *Allow* (or *Always Allow*). If you'd
rather not touch the keychain, pass `--password` explicitly.

## Notes

- The QR encodes the standard `WIFI:T:WPA;S:<ssid>;P:<password>;;` URI that phone cameras understand.
- Reserved characters in the SSID or password (`\ ; , : "`) are escaped automatically.
- Detecting the *current* network needs an active Wi-Fi association; on Ethernet, pass the SSID by name.

## License

MIT — see [LICENSE](LICENSE).
