import CoreImage
import Foundation

enum QRCode {
    /// Renders `text` as a QR code drawn with ANSI background blocks, sized two
    /// terminal cells per module so it stays roughly square and scannable.
    /// Explicit black/white backgrounds make it readable on any terminal theme.
    static func terminalString(for text: String, quietZone: Int = 2) -> String? {
        guard let matrix = matrix(for: text) else { return nil }

        let dark = "\u{1b}[40m  "   // black background, two spaces
        let light = "\u{1b}[47m  "  // white background, two spaces
        let reset = "\u{1b}[0m"

        let modules = matrix.count
        let size = modules + quietZone * 2
        var out = ""

        for y in 0..<size {
            for x in 0..<size {
                let inside = y >= quietZone && y < modules + quietZone
                    && x >= quietZone && x < modules + quietZone
                let isDark = inside && matrix[y - quietZone][x - quietZone]
                out += isDark ? dark : light
            }
            out += reset + "\n"
        }
        return out
    }

    /// Returns the QR module grid (`true` = dark module).
    private static func matrix(for text: String) -> [[Bool]]? {
        guard let data = text.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let image = filter.outputImage else { return nil }
        // The generator emits exactly one pixel per module, so no scaling.
        let context = CIContext(options: [.useSoftwareRenderer: true])
        guard let cgImage = context.createCGImage(image, from: image.extent),
              let pixels = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(pixels) else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        var matrix = [[Bool]]()
        matrix.reserveCapacity(height)
        for y in 0..<height {
            var row = [Bool]()
            row.reserveCapacity(width)
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                // Dark modules render near-black; sample the red channel.
                row.append(bytes[offset] < 128)
            }
            matrix.append(row)
        }
        return matrix
    }
}
