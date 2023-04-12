//
//  FaceAuthCameraUI.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import SwiftUI
import Combine
import UIKit

// MARK: The FaceAuthAppDelegate
class FaceAuthAppDelegate: UIResponder, UIApplicationDelegate {
    let viewModel: FaceAuthViewModel = FaceAuthViewModel()
    private var cancellables = [AnyCancellable]()
    let captureSession = FaceAuthCaptureSession()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        captureSession.$sampleBuffer
            .subscribe(viewModel.subject).store(in: &cancellables)
        return true
    }
}

// MARK: FaceAuth MainApp
public struct FaceAuthCameraUI: View {
    var configurationBuilder: FaceAuthConfigurationBuilder
    var onResults: (FaceAuthResults) -> Void
    @UIApplicationDelegateAdaptor(FaceAuthAppDelegate.self) private var FaceAuthDelegate
    public init(configurationBuilder:FaceAuthConfigurationBuilder, onResults:@escaping (FaceAuthResults) -> Void){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
    }
    public var body: some View {
        return FaceAuthMainCameraUI(configurationBuilder: configurationBuilder, onResults: onResults, FaceAuthAppDelegate:FaceAuthDelegate)
    }
}

// MARK: The Public FaceAuthMainCameraUI
// Takes in FaceAuthConfigurationBuilder and onResults callback which return FaceAuthResults
private struct FaceAuthMainCameraUI: View {
    var configurationBuilder: FaceAuthConfigurationBuilder
    var onResults: (FaceAuthResults) -> Void
    @State private var FaceAuthDelegate: FaceAuthAppDelegate = FaceAuthAppDelegate()
    init(configurationBuilder:FaceAuthConfigurationBuilder, onResults:@escaping (FaceAuthResults) -> Void, FaceAuthAppDelegate: FaceAuthAppDelegate){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
        self.FaceAuthDelegate = FaceAuthAppDelegate
    }
    var body: some View {
        return _FaceAuthCameraUI(
        configurationBuilder: configurationBuilder, onResults: onResults)
        .environmentObject(FaceAuthDelegate.viewModel)
        .environmentObject(FaceAuthDelegate.captureSession)
    }
}

// MARK: The Private _FaceAuthCameraUI
private struct _FaceAuthCameraUI: View {
    var configurationBuilder: FaceAuthConfigurationBuilder = FaceAuthConfigurationBuilder()
    var onResults: (FaceAuthResults) -> Void = {_ in }
    @EnvironmentObject private var viewModel:FaceAuthViewModel
    @EnvironmentObject private var captureSession: FaceAuthCaptureSession
    
    public init(configurationBuilder:FaceAuthConfigurationBuilder, onResults:@escaping (FaceAuthResults) -> Void){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
    }
    
    public var body: some View {
        return ZStack(alignment:.bottom){
            IOSCameraView()
            SimpleProgressView()
            InstructionText()
            ArrowView()
        }
    }
    
    @ViewBuilder
    private func IOSCameraView() -> some View {
        if #available(iOS 14.0, *) {
            ZStack{
                FaceAuthCameraView(captureSession: self.captureSession.captureSession)
                cameraOverlay()
            }.onDisappear(){
                self.captureSession.stop()
            }
            .onAppear(){
                self.captureSession.start()
            }.onChange(of: self.captureSession.sampleBuffer, perform: { _ in
                //self.viewModel.performFaceAuth()
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder
    private func cameraOverlay() -> some View {
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
    
    @ViewBuilder
    private func ArrowView()->some View {
        Group{
            if self.viewModel.direction == "Look Left" {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.viewModel.direction == "Look Right" {
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.viewModel.direction == "Look Up" {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            if self.viewModel.direction == "Look Down" {
                Image(systemName: "arrow.down")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
        }
    }

    
    @ViewBuilder
    private func SimpleProgressView() -> some View {
        if #available(iOS 14.0, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            ActivityIndicator(style: .medium)
        }
    }

    
    @ViewBuilder
    private func InstructionText() -> some View {
        Text(self.viewModel.direction)
            .foregroundColor(Color.white)
            .padding()
    }
}

// MARK: The ProgressView to support older ios verions
private struct ActivityIndicator: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        UIViewType(style: style)
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        uiView.style = style
        uiView.hidesWhenStopped = true
        uiView.startAnimating()
    }
}

// MARK: USAGE
/*
 FaceAuthCameraUI(
     configurationBuilder: FaceAuthConfigurationBuilder()
         .setUserLicense(userLicense: "1234"),
     onResults: {FaceAuthResults in print(FaceAuthResults)}
 )
 */
