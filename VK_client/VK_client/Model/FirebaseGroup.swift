//
//  FirebaseGroup.swift
//  VK_client
//
//  Created by Зинде Иван on 9/6/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import FirebaseDatabase

//Класс группы для Firebase
class FirebaseGroup {
    let id: Int
    let name: String
    let screenName: String
    let photo50: String
    
    let ref: DatabaseReference?
    
    init(id: Int, name: String, screenName: String, photo50: String) {
        self.id = id
        self.name = name
        self.screenName = screenName
        self.photo50 = photo50
        self.ref = nil
    }
    convenience init(from groupModel : Group) {
        self.init( id : groupModel.id,
                   name : groupModel.name,
                   screenName : groupModel.screenName,
                   photo50 : groupModel.photo50)
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else { return nil }
        
        guard let id = value["id"] as? Int,
            let name = value["name"] as? String,
            let screenName = value["screenName"] as? String,
            let photo50 = value["photo50"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.screenName = screenName
        self.photo50 = photo50
        self.ref = snapshot.ref
    }
    
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let screenName = dict["screenName"] as? String,
            let photo50 = dict["photo50"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.screenName = screenName
        self.photo50 = photo50
        self.ref = nil
    }
    
    func toAnyObject() -> [String: Any] {
        [
            "id": id,
            "name": name,
            "screenName": screenName,
            "photo50": photo50,
        ]
    }
}
