//
//  SessionManger.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-01.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()
    var currentUserId: String? {
        didSet {
            NotificationCenter.default.post(name: .didUpdateUserId, object: nil)
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        }
    }
}
