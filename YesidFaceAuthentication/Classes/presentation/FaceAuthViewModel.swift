import SwiftUI
import Foundation
import Vision
import UIKit
import Combine
import AVFoundation

public class FaceAuthViewModel: NSObject, ObservableObject {
    
    private var apiEndpoint = "https://faceapi.regulaforensics.com/api/match"
        
    @Published public var direction:String = ""
    
    @Published public var authenticatedFace:UIImage?
    @Published public var authenticatedFaceBase64Image:String?
    
    @Published private var yaw: Float = 0
    @Published private var roll: Float = 0
    @Published private var pitch: Float = 0
    @Published private var boundingBox = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    @Published private var landmarks: VNFaceLandmarks2D?
    
    @Published var faceCaptureQuality: Float = 0.0
    @Published private var capturePhoto:Bool = false
    
    private var sampleBuffer: CMSampleBuffer?
    public let subject = PassthroughSubject<CMSampleBuffer?, Never>()
    private var cancellables = [AnyCancellable]()
    
    @Published public var faceMatchResults = Result()
    @Published public var isLoading = false
    @Published public var isResultSet:Bool = false
    @Published public var isError:Bool = false
    @Published public var enrollmentProgress:Int = 0
    
    public override init() {
        super.init()
        subject.sink { sampleBuffer in
            self.sampleBuffer = sampleBuffer
            do {
                guard let sampleBuffer = sampleBuffer else {
                    return
                }
                try self.detect(sampleBuffer: sampleBuffer)
            } catch {
                print("Error has been thrown")
            }
            
        }.store(in: &cancellables)
    }
    
    private func detect(sampleBuffer: CMSampleBuffer) throws {
        let handler = VNSequenceRequestHandler()
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest{ (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
        
        let faceCaptureQualityRequest = VNDetectFaceCaptureQualityRequest{ (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        
        let faceRectanglesRequest = VNDetectFaceRectanglesRequest{ (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        if #available(iOS 15.0, *) {
            faceLandmarksRequest.revision = VNDetectFaceRectanglesRequestRevision3
        } else {
            // Fallback on earlier versions
        }
        
        DispatchQueue.global().async {
            do {
                if #available(iOS 14.0, *) {
                    try handler.perform([faceLandmarksRequest, faceCaptureQualityRequest, faceRectanglesRequest], on: sampleBuffer, orientation: .left)
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                // don't do anything
            }
        }
        
    }
    
    private func handleRequests(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard
                let imageBuffer = self.sampleBuffer,
                let results = request.results as? [VNFaceObservation],
                let result = results.first else { return }
            
            self.boundingBox = result.boundingBox
            
            if #available(iOS 15.0, *) {
                if let yaw = result.yaw,
                   let pitch = result.pitch,
                   let roll = result.roll {
                    self.yaw = yaw.floatValue
                    self.pitch = pitch.floatValue
                    self.roll = roll.floatValue
                }
            } else {
                // Fallback on earlier versions
            }
            
            if let landmarks = result.landmarks {
                self.landmarks = landmarks
            }
            
            if let captureQuality = result.faceCaptureQuality {
                self.faceCaptureQuality = captureQuality
            }
            self.performFaceAuthentication()
            if(self.enrollmentProgress==100 && self.authenticatedFace==nil){
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.capturePhoto = true
                }
                
                if self.capturePhoto {
                    self.capturePhoto = false
                    self.doFaceMatch(result, from: imageBuffer)
                }
            }
        }
    }
    
    public func getMatchResults()-> Result{
        return faceMatchResults
    }
    
    public func clearData(){
        DispatchQueue.main.async {
            self.faceMatchResults = Result()
            self.isLoading = false
            self.authenticatedFace = nil
            self.enrollmentProgress = 0
            self.isResultSet = false
        }
    }
    public func matchFaces(face1:String, face2:String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard let url = URL(string: apiEndpoint) else {
            DispatchQueue.main.async {
                self.faceMatchResults = Result()
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = """
        {"images":[{"data":"\(face1)","index":0,"detectAll":true,"type":3},{"data":"\(face2)","index":1,"detectAll":true,"type":3}],"processParams":{"alreadyCropped":true},"thumbnails":true}
        """
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.faceMatchResults = Result()
                    self.isLoading = false
                    self.isError = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.faceMatchResults = Result()
                    self.isLoading = false
                    self.isError = true
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(FaceMatchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.faceMatchResults = response.results?.first ?? Result()
                    self.isLoading = false
                    self.isResultSet = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.faceMatchResults = Result()
                    self.isLoading = false
                    self.isError = true
                }
            }
        }
        task.resume()
    }
    
    private func sendFaceDirection(direction:String){
        self.direction = direction
    }
    
    private func updateEnrollmentProgress(currentProgress:Int){
        self.enrollmentProgress = currentProgress
    }
    
    private func performFaceAuthentication(){
        switch self.enrollmentProgress {
        case 0:
            sendFaceDirection(direction: "Look Left")
            checkFaceDirection(yaw: self.yaw, pitch: self.pitch, roll: self.roll)
        case 20:
            sendFaceDirection(direction: "Look Right")
            checkFaceDirection(yaw: self.yaw, pitch: self.pitch, roll: self.roll)
        case 40:
            sendFaceDirection(direction: "Look Up")
            checkFaceDirection(yaw: self.yaw, pitch: self.pitch, roll: self.roll)
        case 60:
            sendFaceDirection(direction: "Look Down")
            checkFaceDirection(yaw: self.yaw, pitch: self.pitch, roll: self.roll)
        case 80:
            sendFaceDirection(direction: "Look Center")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.checkFaceDirection(yaw: self.yaw, pitch: self.pitch, roll: self.roll)
            }
        case 100:
            sendFaceDirection(direction: "Processing image")
        default:
            self.enrollmentProgress = 80
        }
    }
    
    private func checkFaceDirection(
        yaw:Float,pitch:Float,roll:Float){
            if yaw > 0.3 && self.direction == "Look Left" {
                updateEnrollmentProgress(currentProgress: self.enrollmentProgress+20)
            } else if yaw < -0.3 && self.direction == "Look Right" {
                updateEnrollmentProgress(currentProgress: self.enrollmentProgress+20)
            } else if pitch > 0.3 && self.direction == "Look Down" {
                updateEnrollmentProgress(currentProgress: self.enrollmentProgress+20)
            } else if pitch < -0.3 && self.direction == "Look Up" {
                updateEnrollmentProgress(currentProgress: self.enrollmentProgress+20)
            } else if self.direction == "Look Center" {
                if self.checkFaceBoundsCenter(boundingBox: self.boundingBox) {
                    self.updateEnrollmentProgress(currentProgress: self.enrollmentProgress+20)
                }
            }
        }
    
    private func checkFaceBoundsCenter(boundingBox: CGRect)->Bool{
        // check if boundingBox is at the center of the screen
        let centerX = boundingBox.origin.x + boundingBox.size.width/2
        let centerY = boundingBox.origin.y + boundingBox.size.height/2
        if centerX > 0.4 && centerX < 0.6 && centerY > 0.4 && centerY < 0.6 {
            return true
        }
        return false
    }
    
    private func doFaceMatch(_ observation: VNFaceObservation, from buffer: CMSampleBuffer) {
        let imageBuffer = CMSampleBufferGetImageBuffer(buffer)
        let ciImage = CIImage(cvPixelBuffer: imageBuffer!)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!).fixedOrientation().imageRotatedByDegrees(degrees: 90)
        self.authenticatedFace = uiImage
       let base64StringImage = self.convertImageToBase64String(img: uiImage)
        self.authenticatedFaceBase64Image = base64StringImage
    }
    
    public func convertImageToBase64String(img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.2)?.base64EncodedString() ?? ""
    }
    
    public func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
}


