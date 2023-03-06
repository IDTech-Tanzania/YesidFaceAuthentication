// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let regulaResponse = try? newJSONDecoder().decode(RegulaResponse.self, from: jsonData)

import Foundation

// MARK: - FaceMatchResponse
struct FaceMatchResponse: Codable {
    var errorCode, code: Int?
    var detections: [Detection]?
    var results: [Result]?

    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case code, detections, results
    }
}

// MARK: - Detection
struct Detection: Codable {
    var faces: [Face]?
    var imageIndex, status: Int?
}

// MARK: - Face
struct Face: Codable {
    var faceIndex: Int?
    var landmarks: [[Int]]?
    var roi: [Int]?
    var rotationAngle: Double?
    var thumbnail: String?
}

// MARK: - Result
public struct Result: Codable {
    var first, firstFaceIndex, firstIndex: Int?
    var score: Double?
    var second, secondFaceIndex, secondIndex: Int?
    public var similarity: Double?
}
