//
//  main.swift
//  swift-apn
//
//  Created by Florian Reinhart on 16/11/2016.
//
//

import Foundation

private let privateKey = "-----BEGIN PRIVATE KEY-----\n*******YOUR PRIVATE KEY*******\n-----END PRIVATE KEY-----"

let deviceToken = try! DeviceToken(hexString: "YOUR DEVICE TOKEN")

let jwt = try! JSONWebToken(privateKey: privateKey.data(using: .utf8)!, keyId: "YOUR KEY ID", teamId: "YOUR TEAM ID")
let provider = PushProvider(jsonWebToken: jwt, production: true)

var notification = PushNotification()
notification.topic = "YOUR TOPIC"
notification.alertTitle = "Swift!"
notification.alertBody = "Hello from Swift!"
notification.sound = "default"

provider.send(notification: notification, to: deviceToken) { error in
    if let error = error {
        print("Sending notification failed: \(error)")
    } else {
        print("Notification sent successfully")
    }
}

RunLoop.current.run()
