//
//  DeviceToken.swift
//  swift-apn
//
//  Created by Florian Reinhart on 15/11/2016.
//
//

import Foundation

enum APNDeviceTokenError: Error {
    case emptyToken
    case invalidToken
}

public struct APNDeviceToken: RawRepresentable {
    
    private static let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdef")
    
    public let rawValue: String
    
    public var hexString: String {
        return self.rawValue
    }
    
    public var data: Data {
        return Data()
    }
    
    public init?(rawValue: String) {
        try? self.init(hexString: rawValue)
    }
    
    public init(hexString: String) throws {
        guard !hexString.isEmpty else {
            throw APNDeviceTokenError.emptyToken
        }
        
        self.rawValue = hexString.lowercased()
        
        guard self.rawValue.trimmingCharacters(in: APNDeviceToken.hexCharacterSet).isEmpty else {
            throw APNDeviceTokenError.invalidToken
        }
    }
    
    public init(data: Data) throws {
        guard !data.isEmpty else {
            throw APNDeviceTokenError.emptyToken
        }
        
        self.rawValue = data.reduce("") { hexString, byte in
            return hexString.appendingFormat("%02hhx", byte)
        }
    }
}
