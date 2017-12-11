//
//  UserProfile.swift
//  App
//
//  Created by Lucas Assis Rodrigues on 10/12/2017.
//  Copyright © 2017 Apple Dev Academy. All rights reserved.
//

import ConnectivityServices

public class UserProfile: ProfileRequirements {
    
    private let _id: String
    private var _userName: String
    private var _avatar: String
    
    public var id: String {
        get {
            
            return self._id
        }
    }
    
    public var userName: String {
        get {
            
            return self._userName
        }
        
        set(userName) {
            self._userName = userName
        }
    }
    
    public var avatar: String {
        get {
            
            return self._avatar
        }
        
        set(avatar) {
            
            self._avatar = avatar
        }
    }
    
    public init(id: String, userName: String, avatar: String) {
        self._id = id
        self._userName = userName
        self._avatar = avatar
    }
}

public extension String {
    
    public static func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(UInt32(allowedChars.count)))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}