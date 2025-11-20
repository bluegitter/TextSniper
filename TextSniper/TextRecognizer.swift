//
//  TextRecognizer.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit
import Foundation

enum RecognitionLanguage: String, CaseIterable, Identifiable {
    case english = "英语"
    case chineseSimplified = "简体中文"
    case chineseTraditional = "繁体中文"
    case japanese = "日语"
    case korean = "韩语"
    case french = "法语"
    case german = "德语"

    var id: String { rawValue }
}

final class TextRecognizer {
    enum RecognitionError: Error, LocalizedError {
        case missingImageData
        case invalidResponse
        case apiFailure(String)

        var errorDescription: String? {
            switch self {
            case .missingImageData:
                return "无法读取截屏图像。"
            case .invalidResponse:
                return "识别服务返回了无法解析的结果。"
            case .apiFailure(let message):
                return message
            }
        }
    }

    struct APIResponse: Decodable {
        struct Page: Decodable {
            let page: Int?
            let text: [String]?
        }

        let code: Int
        let data: [Page]?
        let msg: String?
    }

    private let session: URLSession
    private let endpoint: URL

    init(session: URLSession = .shared, endpoint: URL = URL(string: "http://192.168.64.20:8001/ocr/basic_text_recognize_with_file")!) {
        self.session = session
        self.endpoint = endpoint
    }

    func recognize(
        in image: NSImage,
        language: RecognitionLanguage,
        autoDetect: Bool,
        customWords: [String],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let pngData = image.pngData else {
            completion(.failure(RecognitionError.missingImageData))
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"ofile\"; filename=\"capture.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(pngData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("[TextRecognizer] Sending OCR request (\(pngData.count) bytes) to \(endpoint.absoluteString)")

        session.dataTask(with: request) { data, response, error in
            if let error {
                print("[TextRecognizer] Request failed with error: \(error)")
                completion(.failure(error))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data
            else {
                print("[TextRecognizer] Invalid HTTP response: \(String(describing: response))")
                completion(.failure(RecognitionError.invalidResponse))
                return
            }

            do {
                if let raw = String(data: data, encoding: .utf8) {
                    print("[TextRecognizer] Raw response: \(raw)")
                }

                let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                guard decoded.code == 200, let pages = decoded.data else {
                    let message = decoded.msg ?? "识别失败，错误代码 \(decoded.code)"
                    print("[TextRecognizer] API responded with error: \(message)")
                    completion(.failure(RecognitionError.apiFailure(message)))
                    return
                }

                let texts = pages.flatMap { $0.text ?? [] }.filter { !$0.isEmpty }
                guard !texts.isEmpty else {
                    print("[TextRecognizer] No text returned in payload.")
                    completion(.failure(RecognitionError.invalidResponse))
                    return
                }

                print("[TextRecognizer] Successfully recognized text.")
                completion(.success(texts.joined(separator: "\n")))
            } catch {
                print("[TextRecognizer] Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

extension NSImage {
    var pngData: Data? {
        guard
            let tiff = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let data = bitmap.representation(using: .png, properties: [:])
        else {
            return nil
        }
        return data
    }
}
