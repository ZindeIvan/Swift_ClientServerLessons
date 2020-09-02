//
//  User.swift
//  VK_client
//
//  Created by Зинде Иван on 7/9/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import RealmSwift

//Класс пользователь
class User: Object, Decodable{
    @objc dynamic var id: Int = 0
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var online: Int = 0
    @objc dynamic var photo50: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case online
        case photo50 = "photo_50"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.online = try values.decode(Int.self, forKey: .online)
        self.photo50 = try values.decode(String.self, forKey: .photo50)
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
