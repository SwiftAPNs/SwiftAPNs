//
//  Notification.swift
//  swift-apn
//
//  Created by Florian Reinhart on 15/11/2016.
//
//

import Foundation

public struct PushNotification {
    
    public enum Error: Swift.Error {
        case invalidPayloadDictionary
    }
    
    public enum Priority {
        case low
        case high
        
        internal var stringValue: String {
            switch self {
            case .low:
                return "5"
            case .high:
                return "10"
            }
        }
    }
    
    private enum Keys {
        static let aps = "aps"
        static let alert = "alert"
        static let badge = "badge"
        static let sound = "sound"
        static let contentAvailable = "content-available"
        static let mutableContent = "mutable-content"
        static let category = "category"
        static let threadId = "thread-id"
        
        enum Alert {
            static let body = "body"
            static let locKey = "loc-key"
            static let locArgs = "loc-args"
            static let title = "title"
            static let titleLocKey = "title-loc-key"
            static let titleLocArgs = "title-loc-args"
            static let actionLocKey = "action-loc-key"
            static let launchImage = "launch-image"
        }
    }
    
    private var aps = [String : Any]()
    
    private var alertDictionary: [String : Any]? {
        return self.aps[Keys.alert] as? [String : Any]
    }
    
    private mutating func updateAlertDictionary(key: String, value: Any?) {
        // Create alert dictionary if needed
        var alertDictionary: [String : Any]
        if let alertBody = self.aps[Keys.alert] as? String {
            alertDictionary = [Keys.Alert.body: alertBody]
        } else {
            alertDictionary = self.alertDictionary ?? [:]
        }
        
        alertDictionary[key] = value
        self.aps[Keys.alert] = alertDictionary
    }
    
    public var alertBody: String? {
        get {
            return (self.aps[Keys.alert] as? String) ??
                self.alertDictionary?[Keys.Alert.body] as? String
        }
        set {
            if var alertDictionary = self.alertDictionary {
                alertDictionary[Keys.Alert.body] = newValue
                self.aps[Keys.alert] = alertDictionary
            } else {
                self.aps[Keys.alert] = newValue
            }
        }
    }
    
    public var alertLocKey: String? {
        get { return self.alertDictionary?[Keys.Alert.locKey] as? String }
        set { self.updateAlertDictionary(key: Keys.Alert.locKey, value: newValue) }
    }
    
    public var alertLocArgs: [String]? {
        get { return self.alertDictionary?[Keys.Alert.locArgs] as? [String] }
        set { self.updateAlertDictionary(key: Keys.Alert.locArgs, value: newValue) }
    }
    
    public var alertTitle: String? {
        get { return self.alertDictionary?[Keys.Alert.title] as? String }
        set { self.updateAlertDictionary(key: Keys.Alert.title, value: newValue)}
    }
    
    public var alertTitleLocKey: String? {
        get { return self.alertDictionary?[Keys.Alert.titleLocKey] as? String }
        set { self.updateAlertDictionary(key: Keys.Alert.titleLocKey, value: newValue)}
    }
    
    public var alertTitleLocArgs: [String]? {
        get { return self.alertDictionary?[Keys.Alert.titleLocArgs] as? [String] }
        set { self.updateAlertDictionary(key: Keys.Alert.titleLocArgs, value: newValue)}
    }
    
    public var alertActionLocKey: String? {
        get { return self.alertDictionary?[Keys.Alert.actionLocKey] as? String }
        set { self.updateAlertDictionary(key: Keys.Alert.actionLocKey, value: newValue)}
    }
    
    public var alertLaunchImage: String? {
        get { return self.alertDictionary?[Keys.Alert.launchImage] as? String }
        set { self.updateAlertDictionary(key: Keys.Alert.launchImage, value: newValue)}
    }
    
    public var badge: Int? {
        get { return self.aps[Keys.badge] as? Int }
        set { self.aps[Keys.badge] = newValue }
    }
    
    public var sound: String? {
        get { return self.aps[Keys.sound] as? String }
        set { self.aps[Keys.sound] = newValue }
    }
    
    public var contentAvailable: Bool? {
        get { return (self.aps[Keys.contentAvailable] as? Int).flatMap { $0 == 1 ? true : false } }
        set { self.aps[Keys.contentAvailable] = newValue.flatMap { $0 ? 1 : 0 } }
    }
    
    public var mutableContent: Bool? {
        get { return (self.aps[Keys.mutableContent] as? Int).flatMap { $0 == 1 ? true : false } }
        set { self.aps[Keys.mutableContent] = newValue.flatMap { $0 ? 1 : 0 } }
    }
    
    public var category: String? {
        get { return self.aps[Keys.category] as? String }
        set { self.aps[Keys.category] = newValue }
    }
    
    public var threadId: String? {
        get { return self.aps[Keys.threadId] as? String }
        set { self.aps[Keys.threadId] = newValue }
    }
    
    public private(set) var payload: [String : Any]?
    
    public var uuid: UUID?
    
    public var expiration: Date?
    
    public var priority: Priority?
    
    public var topic: String?
    
    public var collapseId: String?
    
    public mutating func updatePayload(with dictionary: [String : Any]?) throws {
        if let dictionary = dictionary {
            guard JSONSerialization.isValidJSONObject(dictionary) else {
                throw Error.invalidPayloadDictionary
            }
            self.payload = dictionary
        } else {
            self.payload = nil
        }
    }
    
    var jsonData: Data {
        // Combine aps and payload dictionary
        var dictionary = self.payload ?? [:]
        dictionary[Keys.aps] = self.aps
        return try! JSONSerialization.data(withJSONObject: dictionary)
    }
}
