//
//  DeviceToken.swift
//  swift-apn
//
//  Created by Florian Reinhart on 15/11/2016.
//
//

import Foundation

public struct DeviceToken: RawRepresentable {
    
    public enum Error: Swift.Error {
        case emptyToken
        case invalidToken
    }
    
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
            throw Error.emptyToken
        }
        
        self.rawValue = hexString.lowercased()
        
        guard self.rawValue.trimmingCharacters(in: DeviceToken.hexCharacterSet).isEmpty,
            self.rawValue.count % 2 == 0 else {
                throw Error.invalidToken
        }
    }
    
    public init(data: Data) throws {
        guard !data.isEmpty else {
            throw Error.emptyToken
        }
        
        self.rawValue = data.reduce("") { hexString, byte in
            return hexString.appendingFormat("%02hhx", byte)
        }
    }
}
