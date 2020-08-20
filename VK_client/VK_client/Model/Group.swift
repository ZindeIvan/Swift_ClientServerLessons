//
//  Group.swift
//  VK_client
//
//  Created by Зинде Иван on 7/10/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import RealmSwift

//Класс Группы
struct Group {
    //Свойство названия группы
    let groupName : String
    //Свойство идентификатора группы
    let groupID : String
    
    let groupPhoto : String
}

//Расширим класс для возможности указания равенства экземпляров класса
extension Group : Equatable {
    static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.groupID == rhs.groupID
    }
}

//Расширим класс для возможности сравнения экземпляров класса
extension Group : Comparable {
    static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.groupID < rhs.groupID
    }
}

//Классы парсинга JSON

class GroupQuery : Decodable{
    var response : GroupResponse
}

class GroupResponse : Decodable{
    let count: Int = 0
    var items: [GroupItem]
}

class GroupItem: Object, Decodable , Itemable{
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var photo50: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case screenName = "screen_name"
        case photo50 = "photo_50"
    }
    
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.screenName = try values.decode(String.self, forKey: .screenName)
        self.photo50 = try values.decode(String.self, forKey: .photo50)
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
