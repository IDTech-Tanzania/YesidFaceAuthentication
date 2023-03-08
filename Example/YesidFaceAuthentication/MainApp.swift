import SwiftUI
import YesidFaceAuthentication

struct MainApp: View {
    @State var appDelegate: AppDelegate = AppDelegate()
    var body: some View {
        FaceAuthenticationScreen()
        .environmentObject(appDelegate.faceAuthCaptureSession)
        .environmentObject(appDelegate.faceAuthModel)
        .onDisappear(){
            self.appDelegate.faceAuthCaptureSession.stop()
        }
        .onAppear(){
            self.appDelegate.faceAuthCaptureSession.start()
        }
    }
}

struct FaceAuthenticationScreen: View {
    @EnvironmentObject var faceAuthModel:FaceAuthenticationViewModel
    @EnvironmentObject var faceAuthCaptureSession: FaceAuthCaptureSession
    var body: some View {
        ScrollView{
                AuthenticationCameraView()
                AuthenticationCaptureImageView()
                AuthenticationErrorView()
            }
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .topLeading)
            .padding(.horizontal, 10.0)
    }
    @ViewBuilder
    func AuthenticationCameraView()->some View{
        if(self.faceAuthModel.authenticatedFace == nil ){
            HStack{
                ZStack {
                    YesidFaceAuthentication()
                        .environmentObject(faceAuthModel)
                        .cornerRadius(6)
                }
            }
            .cornerRadius(6)
            .padding(.vertical,10)
            .frame(maxWidth:.infinity)
            .frame(height:UIScreen.screenHeight/2)
        }
    }
    @ViewBuilder
    func AuthenticationCaptureImageView()->some View{
        if(self.faceAuthModel.enrollmentProgress==100 && self.faceAuthModel.authenticatedFace != nil){
            VStack {
                ZStack{
                    SwiftUI.Image(uiImage: self.faceAuthModel.authenticatedFace ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height:UIScreen.screenHeight/2)
                        .clipShape(Rectangle())
                        .cornerRadius(6)
                        .onAppear(){
                            let queue = DispatchQueue(label:"io.yesid.sdk.ios",attributes: .concurrent)
                            queue.async {
                                self.faceAuthCaptureSession.stop()
                            }
                            queue.async {
                                Task{
                                    await self.faceAuthModel.matchFaces(face1: self.faceAuthModel.authenticatedFaceBase64Image!, face2: self.faceAuthModel.authenticatedFaceBase64Image!)
                                }
                            }
                        }
                    if(self.faceAuthModel.isResultSet == true){
                        withAnimation{
                            Button(
                                "Recapture",
                                action: {
                                    self.faceAuthModel.clearData()
                                    self.faceAuthCaptureSession.start()
                                })
                            .frame(maxWidth: .infinity, maxHeight: 459.0, alignment: .bottom)
                            .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 25.0)
                        }
                    }
                }
                .padding(.vertical,10)
            }
        }
    }
    
    @ViewBuilder
    func AuthenticationErrorView()->some View{
        VStack(alignment:.center,spacing: 10){
            if(self.faceAuthModel.getMatchResults().similarity ?? 0 > 0.0 && self.faceAuthModel.getMatchResults().similarity ?? 0 > 0.0){
                Text("Match score : ")
            }else{
                if(self.faceAuthModel.enrollmentProgress == 100){
                    HStack{
                        if(self.faceAuthModel.isError == true){
                            Text("Auth Error")
                                .fixedSize(horizontal: false, vertical: true)
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        self.faceAuthModel.clearData()
                                        self.faceAuthCaptureSession.start()
                                    }
                                }
                        }else{
                            Text("Matching")
                                .fixedSize(horizontal: false, vertical: true)
                            if #available(iOS 14.0, *) {
                                ProgressView()
                            }
                        }
                    }
                    .frame(maxWidth:.infinity)
                    .frame(alignment: .center)
                }
            }
            Spacer()
        }
        .frame(maxWidth:.infinity)
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
