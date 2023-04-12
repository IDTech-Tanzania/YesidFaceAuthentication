# yes:ID IOS Face Authentication SDK

# Installation
You can install the YesidFaceAuthentication library using CocoaPods. Add the following line to your project's Podfile:

`pod 'YesidFaceAuthentication'`

Then run `pod install` command to install the library.

# Import the YesidFaceAuthentication module:

In your project's Swift file where you want to use the YesidFaceAuthentication library, add the following import statement:

```
import YesidFaceAuthentication
```

# Instantiate and present the FaceAuthenticationCameraUI view:

`Configure the SDK by passing the license or anyother configuration`

```
let configuration: FaceAuthConfigurationBuilder = FaceAuthConfigurationBuilder().setUserLicense(userLicense: "YOUR_LICENSE")

```
` Use the SDK by calling FaceAuthenCameraUI`
```
@main
struct iOSApp: App {
    var body: some Scene {
        WindowGroup {
                FaceAuthCameraUI(configurationBuilder: configuration) { response in
                    print(response)
                }
        }
    }
}
```

# Handle FaceAuthentication responses:

When the FaceAuthentication process completes, the FaceAuthCameraUI view will call the callback function you provided with the FaceAuthentication results. You can handle the results accordingly in your app.



