//
//  CaptureSession.swift
//  object-detection
//
//  Created by Aim Group on 19/09/2022.
//

import Foundation
import AVFoundation
import SwiftUI

public class FaceAuthCaptureSession: NSObject, ObservableObject {
    
    enum Status {
      case unconfigured
      case configured
      case unauthorized
      case failed
    }

    @Published var error: CameraError?
    @Published public var sampleBuffer: CMSampleBuffer?
    @Published var orientation: AVCaptureDevice.Position?

    let captureSession = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "io.yesid.sdk")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status = Status.unconfigured

    private func set(error: CameraError?) {
      DispatchQueue.main.async {
        self.error = error
      }
    }
    
    private func checkPermissions() {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .notDetermined:
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { authorized in
          if !authorized {
            self.status = .unauthorized
            self.set(error: .deniedAuthorization)
          }
          self.sessionQueue.resume()
        }
      case .restricted:
        status = .unauthorized
        set(error: .restrictedAuthorization)
      case .denied:
        status = .unauthorized
        set(error: .deniedAuthorization)
      case .authorized:
        break
      @unknown default:
        status = .unauthorized
        set(error: .unknownAuthorization)
      }
    }
    
    private func configureCaptureSession() {
      guard status == .unconfigured else {
        return
      }

      captureSession.beginConfiguration()

      defer {
        captureSession.commitConfiguration()
      }
      let device = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: self.orientation ?? .front)
      guard let camera = device else {
        set(error: .cameraUnavailable)
        status = .failed
        return
      }

      do {
        let cameraInput = try AVCaptureDeviceInput(device: camera)
        if captureSession.canAddInput(cameraInput) {
          captureSession.addInput(cameraInput)
        } else {
          set(error: .cannotAddInput)
          status = .failed
          return
        }
      } catch {
          //set(error: .createCaptureInput(error))
        status = .failed
        return
      }

      if captureSession.canAddOutput(videoOutput) {
          videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "SampleBuffer"))
          videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        captureSession.addOutput(videoOutput)
      } else {
        set(error: .cannotAddOutput)
        status = .failed
        return
      }

      status = .configured
    }
    
    public func start(){
        self.configure()
    }
    
    public func stop(){
        sessionQueue.async {
          self.captureSession.stopRunning()
        }
    }
    
    public func changeOrientation(orientation:AVCaptureDevice.Position){
        self.stop()
        self.orientation = orientation
        self.start()
    }
    
    private func configure() {
      checkPermissions()
      sessionQueue.async {
        self.configureCaptureSession()
        self.captureSession.startRunning()
      }
    }

    func set(
      _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
      queue: DispatchQueue
    ) {
      sessionQueue.async {
        self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
      }
    }
}

extension FaceAuthCaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.sampleBuffer = sampleBuffer
        }
    }
}
