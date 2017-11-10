//
//  Provider.swift
//  swift-apn
//
//  Created by Florian Reinhart on 15/11/2016.
//
//

import Foundation

public final class PushProvider: NSObject, URLSessionDelegate {
    
    public enum Error: Swift.Error {
        case connectionError(underlyingError: Swift.Error?)
        case apnsError(statusCode: Int, content: [String : Any]?)
    }
    
    private let url: URL
    
    private let delegateQueue = OperationQueue()
    private var jsonWebToken: JSONWebToken
    
    init(jsonWebToken: JSONWebToken, production: Bool = false) {
        self.jsonWebToken = jsonWebToken
        
        if production {
            self.url = URL(string: "https://api.push.apple.com/3/device/")!
        } else {
            self.url = URL(string: "https://api.development.push.apple.com/3/device/")!
        }
    }
    
    private lazy var session: URLSession = {
        #if os(Linux)
            let configuration = URLSessionConfiguration.default
        #else
            let configuration = URLSessionConfiguration.ephemeral
        #endif
        return URLSession(configuration: configuration, delegate: self, delegateQueue: self.delegateQueue)
    }()
    
    // Completion handler is called on a background queue
    public func send(notification: PushNotification, to recipient: DeviceToken, completionHandler: @escaping (_ error: Error?) -> Void) {
        let url = self.url.appendingPathComponent(recipient.hexString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.addValue("bearer \(self.jsonWebToken.token)", forHTTPHeaderField: "authorization")
        if let topic = notification.topic {
            request.addValue(topic, forHTTPHeaderField: "apns-topic")
        }
        if let uuid = notification.uuid {
            request.addValue(uuid.uuidString.lowercased(), forHTTPHeaderField: "apns-id")
        }
        if let expiration = notification.expiration {
            request.addValue("\(UInt64(expiration.timeIntervalSince1970))", forHTTPHeaderField: "apns-expiration")
        }
        if let priority = notification.priority {
            request.addValue(priority.stringValue, forHTTPHeaderField: "apns-priority")
        }
        if let collapseId = notification.collapseId {
            request.addValue(collapseId, forHTTPHeaderField: "apns-collapse-id")
        }
        
        // Create JSON
        request.httpBody = notification.jsonData
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    completionHandler(nil)
                } else {
                    var content: [String : Any]?
                    if let data = data {
                        content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any]
                    }
                    completionHandler(.apnsError(statusCode: response.statusCode, content: content))
                }
            } else {
                completionHandler(.connectionError(underlyingError: error))
            }
        }
        
        task.resume()
    }
}
