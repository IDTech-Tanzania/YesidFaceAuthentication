//
//  FaceAuthResults.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import Foundation


public struct FaceAuthResults {
    var first, firstFaceIndex, firstIndex: Int?
    var score: Double?
    var second, secondFaceIndex, secondIndex: Int?
    public var similarity: Double?
}
