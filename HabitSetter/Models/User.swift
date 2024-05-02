//
//  User.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-30.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var email: String = ""
    var dateCreated: Timestamp = Timestamp(date: Date())  //current time as standard
    var dateEdited: Timestamp = Timestamp(date: Date())   //current time as standard
    var favouriteQoute: String?
    var profileImageUrl: String?
    var userId: String?

    //Normal constructor
    init(id: String? = nil,
         name: String,
         email: String,
         favouriteQoute: String? = "",
         profileImageUrl: String? = "",
         userId: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.favouriteQoute = favouriteQoute
        self.profileImageUrl = profileImageUrl
        self.userId = userId
        self.dateCreated = Timestamp(date: Date())  //set when created
        self.dateEdited = Timestamp(date: Date())   //set when created
    }


    //extra init for firestore, not exactly sure why we need this yet..
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        favouriteQoute = try container.decodeIfPresent(String.self, forKey: .favouriteQoute)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        dateEdited = try container.decode(Timestamp.self, forKey: .dateEdited)
    }
}
