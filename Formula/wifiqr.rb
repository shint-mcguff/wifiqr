class Wifiqr < Formula
  desc "Show a QR code that joins a Wi-Fi network"
  homepage "https://github.com/shint-mcguff/wifiqr"
  url "https://github.com/shint-mcguff/wifiqr/releases/download/v0.1.0/wifiqr-v0.1.0-universal-macos.tar.gz"
  # Filled in after the v0.1.0 release asset is built by CI.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  version "0.1.0"

  depends_on :macos

  def install
    bin.install "wifiqr"
  end

  test do
    assert_equal "0.1.0", shell_output("#{bin}/wifiqr --version").strip
    assert_match "WIFI:T:WPA;S:TestNet;P:secret;;",
                 shell_output("#{bin}/wifiqr TestNet --password secret --no-qr")
  end
end
