import SwiftUI
import Combine
import YesidFaceAuthentication

class AppDelegate: UIResponder, UIApplicationDelegate {

    let faceAuthModel = FaceAuthenticationViewModel()
    let faceAuthCaptureSession = FaceAuthCaptureSession()
    
    var cancellables = [AnyCancellable]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        faceAuthCaptureSession.$sampleBuffer
            .subscribe(faceAuthModel.subject).store(in: &cancellables)
       
        return true
    }
}

@main
struct YesIDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            MainApp(appDelegate:appDelegate)
        }
    }
}
