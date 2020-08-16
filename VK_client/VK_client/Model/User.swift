//
//  User.swift
//  VK_client
//
//  Created by Зинде Иван on 7/9/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Класс Пользователь
struct User {
    //Свойство имени пользователя
    let userName : String
    //Свойство идентификатора пользователя
    let userID : String
    
}

//Расширим класс для возможности указания равенства экземпляров класса
extension User : Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userName == rhs.userName
    }
}

//Расширим класс для возможности сравнения экземпляров класса
extension User : Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.userName < rhs.userName
    }
}

class UserQuery : Decodable {
    let response : UserResponse
}

class UserResponse : Decodable {
    let count: Int = 0
    let items: [UserItem]
}

class UserItem: Decodable {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var online: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case online
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.online = try values.decode(Int.self, forKey: .online)
        
    }
}

