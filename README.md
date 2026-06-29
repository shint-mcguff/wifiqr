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
wifiqr                          # no arguments → launch the menu bar app
wifiqr "Cafe Guest"             # QR for a saved network by name
wifiqr "Cafe Guest" -p latte    # supply the password directly (no keychain)
wifiqr "Open Hotspot" --open    # passwordless network
wifiqr --no-qr                  # print the current network's WIFI: string (no QR)
wifiqr --menu                   # explicitly launch the menu bar app
```

Run with **no arguments** and `wifiqr` lives in the menu bar (like a typical menu
bar app); pass a network name or any flag to use it from the command line.

### Menu bar

```sh
wifiqr            # or: wifiqr --menu
```

A 📶 icon appears in the menu bar. Click it and a popover shows a scannable QR
for whatever network you're currently on — hand your screen to a guest and
they're connected in a tap. **Refresh** rebuilds it after you switch networks.
To keep it running across logins, add `wifiqr` as a Login Item in **System
Settings → General → Login Items**.

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
