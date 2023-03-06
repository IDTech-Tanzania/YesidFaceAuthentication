//
//  YesidFaceAuthentication.swift
//  face
//
//  Created by Aim Group on 01/09/2022.
//

import SwiftUI

public struct YesidFaceAuthentication: View {
    @EnvironmentObject var faceAuthViewModel:FaceAuthenticationViewModel
    @EnvironmentObject var captureSession: FaceAuthCaptureSession
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public init(){
        
    }
    
    public var body: some View {
        ZStack(alignment:.center){
            FullCameraView()
            VStack{
                Spacer()
                HStack(spacing:10){
                    SwiftUI.Text("\(self.faceAuthViewModel.direction)")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    ArrowView()
                    if(self.faceAuthViewModel.enrollmentProgress==100){
                        if #available(iOS 14.0, *) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func ArrowView()->some View {
        Group{
            if self.faceAuthViewModel.direction == "Look Left" {
                SwiftUI.Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.faceAuthViewModel.direction == "Look Right" {
                SwiftUI.Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.faceAuthViewModel.direction == "Look Up" {
                SwiftUI.Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.faceAuthViewModel.direction == "Look Down" {
                SwiftUI.Image(systemName: "arrow.down")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
        }
    }
    
    @ViewBuilder
    func MainCameraView() -> some View {
        CameraView(captureSession: self.captureSession.captureSession)
    }
    
    @ViewBuilder
    func FullCameraView() -> some View {
        ZStack{
            MainCameraView()
            GeometryReader { geometry in
                Color.black.opacity(0.9)
                .mask(
                    FaceAuthMaskShape(
                        inset: UIEdgeInsets(top: geometry.size.height / 6,
                                          left: geometry.size.width / 6,
                                          bottom: geometry.size.height / 6,
                                          right: geometry.size.width / 6)
                    ).fill(style: FillStyle(eoFill: true))
                )
            }
        }
        .frame(maxWidth:self.screenWidth,maxHeight: self.screenHeight)
    }
}

struct YesidFaceAuthentication_Previews: PreviewProvider {
    static var previews: some View {
        YesidFaceAuthentication()
    }
}


struct FaceAuthMaskShape : Shape {
    var inset : UIEdgeInsets
    
    func path(in rect: CGRect) -> Path {
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: CGRect(x: rect.midX - 125, y: rect.midY - 125, width: 250, height: 250)))
        return shape
    }
}

