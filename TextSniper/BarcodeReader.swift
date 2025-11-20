//
//  BarcodeReader.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit
import Vision

final class BarcodeReader {
    enum BarcodeError: Error, LocalizedError {
        case missingCGImage
        case noPayload

        var errorDescription: String? {
            switch self {
            case .missingCGImage:
                return "无法读取截取区域的像素。"
            case .noPayload:
                return "未检测到二维码或条码。"
            }
        }
    }

    func read(from image: NSImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(.failure(BarcodeError.missingCGImage))
            return
        }

        let request = VNDetectBarcodesRequest { request, error in
            if let error {
                completion(.failure(error))
                return
            }

            let observations = request.results as? [VNBarcodeObservation] ?? []
            if let payload = observations.first?.payloadStringValue {
                completion(.success(payload))
            } else {
                completion(.failure(BarcodeError.noPayload))
            }
        }

        request.symbologies = [.QR, .Aztec, .dataMatrix, .Code128, .PDF417]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}
