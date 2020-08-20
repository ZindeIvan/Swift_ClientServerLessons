//
//  Photo.swift
//  VK_client
//
//  Created by Зинде Иван on 8/17/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import RealmSwift

//Классы парсинга JSON

class PhotoQuery : Decodable{
    var response : PhotoResponse
}

class PhotoResponse : Decodable{
    let count: Int = 0
    var items: [PhotoItem]
}

class PhotoItem: Object, Decodable, Itemable{
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerID: Int = 0
    @objc var photoSizeX : String = ""
    @objc var photoSizeM : String = ""
    @objc var photoSizeS : String = ""

    enum CodingKeys: String, CodingKey {
    case id
    case ownerID = "owner_id"
    case sizes
    }
    
    enum PhotoKeys: String, CodingKey {
    case height, url, type, width
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.ownerID  = try values.decode(Int.self, forKey: .ownerID)
        
        var photosValues = try values.nestedUnkeyedContainer(forKey: .sizes)
       
        while !photosValues.isAtEnd {
            let photo = try photosValues.nestedContainer(keyedBy: PhotoKeys.self)
            let photoType = try photo.decode(String.self, forKey: .type)
            let photoURL = try photo.decode(String.self, forKey: .url)
            switch photoType {
            case "x":
                photoSizeX = photoURL
            case "s":
                photoSizeS = photoURL
            case "m":
                photoSizeM = photoURL
            default:
                continue
            }
        }
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
