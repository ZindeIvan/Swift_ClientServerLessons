//
//  Photo.swift
//  VK_client
//
//  Created by Зинде Иван on 8/17/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Классы парсинга JSON

class PhotoQuery : Decodable {
    let response : PhotoResponse
}

class PhotoResponse : Decodable {
    let count: Int = 0
    let items: [PhotoItem]
}

class PhotoItem: Decodable {
    dynamic var id: Int = 0
    dynamic var ownerID: Int = 0
    dynamic var photoSizes : [String : String] = [:]

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
            photoSizes[photoType] = photoURL
        }
        
    }
}

