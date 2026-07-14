import AVFoundation
import UIKit
import Vision

enum CodexLabISBNScannerEngine {
    static let captureQueueLabel = "codexlab.isbn.scan"

    static var authorizationStatus: AVAuthorizationStatus {
        SpecimenLensAccess.status
    }

    static func ensureCameraAuthorized() async -> Bool {
        await SpecimenLensAccess.ensure()
    }

    nonisolated static func normalizedISBN(from payload: String) -> String? {
        SpecimenISBNParser.distill(payload)
    }

    static func makeCaptureController() -> SpecimenCaptureRig {
        SpecimenCaptureRig()
    }
}
