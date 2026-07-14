import AVFoundation
import UIKit
import Vision

enum SpecimenISBNParser {
    static let reagents: [VNBarcodeSymbology] = [.ean13, .code128, .ean8, .qr]

    nonisolated static func distill(_ payload: String) -> String? {
        let raw = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        let upper = raw.uppercased()
        if let fromLabel = pullISBNLabel(upper) { return fromLabel }
        let filtered = upper.filter { $0.isNumber || $0 == "X" }
        switch filtered.count {
        case 13...: return String(filtered.suffix(13))
        case 12: return "0" + filtered
        case 10...: return String(filtered.suffix(10))
        default: return nil
        }
    }

    private nonisolated static func pullISBNLabel(_ text: String) -> String? {
        let patterns = [#"isbn[\s:/_-]*([0-9]{13})"#, #"isbn[\s:/_-]*([0-9]{9}[0-9X])"#]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text) else { continue }
            return distill(String(text[range]))
        }
        return nil
    }
}

enum SpecimenLensAccess {
    static var status: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    static func ensure() async -> Bool {
        switch status {
        case .authorized: true
        case .notDetermined:
            await withCheckedContinuation { c in
                AVCaptureDevice.requestAccess(for: .video) { c.resume(returning: $0) }
            }
        default: false
        }
    }
}

final class SpecimenFrameAnalyst: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let onISBN: @Sendable (String) -> Void
    private let mutex = NSLock()
    private var sealed = false

    init(onISBN: @escaping @Sendable (String) -> Void) {
        self.onISBN = onISBN
    }

    func reopen() {
        mutex.lock(); sealed = false; mutex.unlock()
    }

    private func open() -> Bool {
        mutex.lock(); defer { mutex.unlock() }
        return !sealed
    }

    private func seal() -> Bool {
        mutex.lock(); defer { mutex.unlock() }
        if sealed { return false }
        sealed = true
        return true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard open(), let px = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectBarcodesRequest { [weak self] req, _ in
            guard let self, self.open(),
                  let observations = req.results as? [VNBarcodeObservation] else { return }
            for obs in observations {
                guard let payload = obs.payloadStringValue,
                      let isbn = SpecimenISBNParser.distill(payload),
                      self.seal() else { continue }
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    self.onISBN(isbn)
                }
                return
            }
        }
        request.symbologies = SpecimenISBNParser.reagents
        try? VNImageRequestHandler(cvPixelBuffer: px, options: [:]).perform([request])
    }
}

final class SpecimenCaptureRig: UIViewController {
    var onDetect: ((String) -> Void)?
    private let lane = DispatchQueue(label: "codexlab.specimen.scan")
    private let session = AVCaptureSession()
    private var preview: AVCaptureVideoPreviewLayer?
    private var analyst: SpecimenFrameAnalyst?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        lane.async { self.assemble() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyst?.reopen()
        lane.async { if !self.session.isRunning { self.session.startRunning() } }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lane.async { if self.session.isRunning { self.session.stopRunning() } }
    }

    private func assemble() {
        let analyst = SpecimenFrameAnalyst { [weak self] isbn in self?.onDetect?(isbn) }
        self.analyst = analyst
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(analyst, queue: lane)
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(output)
        session.commitConfiguration()
        DispatchQueue.main.async {
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.view.bounds
            self.view.layer.insertSublayer(layer, at: 0)
            self.preview = layer
        }
    }
}
