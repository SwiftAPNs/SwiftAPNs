//
//  JSONWebToken.swift
//  swift-apn
//
//  Created by Florian Reinhart on 16/11/2016.
//
//

import Foundation
import COpenSSL

public struct JSONWebToken {
    
    public enum Error: Swift.Error {
        case invalidPrivateKey
    }
    
    private static let initOpenSSL: () = {
       OPENSSL_add_all_algorithms_conf()
    }()
    
    var token: String
    var issuedAt: Date
    
    private let privateKey: UnsafeMutablePointer<EVP_PKEY>
    private let header: String
    private let teamId: String
    
    public init(privateKey pem: Data, keyId: String, teamId: String) throws {
        JSONWebToken.initOpenSSL
        
        // Load private key
        guard let privateKey = pem.withUnsafeBytes({ (pointer: UnsafePointer<UInt8>) -> UnsafeMutablePointer<EVP_PKEY>? in
            if let bio = BIO_new_mem_buf(pointer, Int32(pem.count)) {
                let privateKey = PEM_read_bio_PrivateKey(bio, nil, nil, nil)
                BIO_free(bio)
                return privateKey
            } else {
                return nil
            }
        }) else {
            throw Error.invalidPrivateKey
        }
        
        let headerDictionary = [
            "alg": "ES256",
            "typ": "JWT",
            "kid": keyId
        ]
        
        self.privateKey = privateKey
        self.header = (try! JSONSerialization.data(withJSONObject: headerDictionary)).base64EncodedString()
        self.teamId = teamId
        (self.token, self.issuedAt) = JSONWebToken.generateToken(privateKey: privateKey, header: header, teamId: teamId)
    }
    
    internal mutating func reissueToken() {
        (self.token, self.issuedAt) = JSONWebToken.generateToken(privateKey: self.privateKey, header: self.header, teamId: self.teamId)
    }
    
    private static func generateToken(privateKey: UnsafeMutablePointer<EVP_PKEY>, header: String, teamId: String) -> (token: String, issuedAt: Date) {
        let issuedAt = Date()
        let claimsDictionary: [String : Any] = [
            // We need to wrap the UInt64 in NSNumber to not crash on Linux when generating the JSON
            "iat": NSNumber(value: UInt64(issuedAt.timeIntervalSince1970)),
            "iss": teamId
        ]
        
        let claims = try! JSONSerialization.data(withJSONObject: claimsDictionary).base64EncodedString()
        
        let content = "\(header).\(claims)"
        
        let signature = JSONWebToken.sign(content: content.data(using: .utf8)!, with: privateKey)
        
        return ("\(content).\(signature.base64EncodedString())", issuedAt)
    }
    
    private static func sign(content: Data, with privateKey: UnsafeMutablePointer<EVP_PKEY>) -> Data {
        // Make sure OpenSSL is loaded
        JSONWebToken.initOpenSSL
        
        let context = EVP_MD_CTX_create()
        let digest = EVP_get_digestbyname("SHA256")
        _ = EVP_DigestInit_ex(context, digest, nil)
        _ = EVP_DigestSignInit(context, nil, digest, nil, privateKey);
        _ = content.withUnsafeBytes { EVP_DigestUpdate(context, $0, content.count) }
        
        // Get length of signature
        var signatureLength = 0
        _ = EVP_DigestSignFinal(context, nil, &signatureLength)
        
        // Get signature
        var signatureArray = Array<UInt8>(repeating: 0, count: signatureLength)
        _ = EVP_DigestSignFinal(context, &signatureArray, &signatureLength)
        
        // Trim array. Sometimes the signature is shorter!?
        signatureArray.removeLast(signatureArray.count - signatureLength)
        
        let data = Data(signatureArray)
        
        // Destory context
        EVP_MD_CTX_destroy(context)
        
        return data
    }
}
