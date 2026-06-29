class Wifiqr < Formula
  desc "Show a QR code that joins a Wi-Fi network"
  homepage "https://github.com/shint-mcguff/wifiqr"
  url "https://github.com/shint-mcguff/wifiqr/releases/download/v0.2.1/wifiqr-v0.2.1-universal-macos.tar.gz"
  # Filled in after the v0.2.1 release asset is built by CI.
  sha256 "b4050e3af267aa786e7135e332dba0ac204e659f2fc28e059f519020e66842c9"
  license "MIT"
  version "0.2.1"

  depends_on :macos

  def install
    bin.install "wifiqr"
  end

  test do
    assert_equal "0.2.1", shell_output("#{bin}/wifiqr --version").strip
    assert_match "WIFI:T:WPA;S:TestNet;P:secret;;",
                 shell_output("#{bin}/wifiqr TestNet --password secret --no-qr")
  end
end
