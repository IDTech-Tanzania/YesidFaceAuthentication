//
//  FaceAuthConfigurationBuilder.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import Foundation

public class FaceAuthConfigurationBuilder {
    public init(){}
    private var userLicense = ""
    public func setUserLicense(userLicense: String) -> FaceAuthConfigurationBuilder {
        self.userLicense = userLicense
        return self
    }
    
    func getUserLicense() -> String {
        return userLicense
    }
    
}

