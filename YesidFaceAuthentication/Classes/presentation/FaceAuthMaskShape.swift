//
//  FaceAuthMaskShape.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import SwiftUI


struct FaceAuthMaskShape : Shape {
    var inset : UIEdgeInsets
    
    func path(in rect: CGRect) -> Path {
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: CGRect(x: rect.midX - 125, y: rect.midY - 125, width: 250, height: 250)))
        return shape
    }
}

