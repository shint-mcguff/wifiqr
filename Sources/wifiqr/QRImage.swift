import AppKit
import CoreImage

enum QRImage {
    /// Renders `text` as a crisp QR `NSImage`. The base image is one pixel per
    /// module scaled up by an integer factor; display it with
    /// `.interpolation(.none)` to keep the edges sharp at any size.
    static func make(for text: String, scale: CGFloat = 10) -> NSImage? {
        guard let data = text.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let rep = NSCIImageRep(ciImage: scaled)
        let image = NSImage(size: rep.size)
        image.addRepresentation(rep)
        return image
    }
}
