//
//  Photo.swift
//  VK_client
//
//  Created by Зинде Иван on 8/17/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

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
//        let photo = try photosValues.nestedContainer(keyedBy: PhotoKeys.self)
//        let photoURL = try photo.decode(String.self, forKey: .url)
        
    }
}
//}
//class PhotoSIze
//
//struct Response: Codable {
//let count: Int
//let items: [Item]
//}
//
//// MARK: - Item
//struct Item: Codable {
//let albumID, date, id, ownerID: Int
//let hasTags: Bool
//let postID: Int
//let sizes: [Size]
//let text: String
//
//enum CodingKeys: String, CodingKey {
//case albumID = "album_id"
//case date, id
//case ownerID = "owner_id"
//case hasTags = "has_tags"
//case postID = "post_id"
//case sizes, text
//}
//}
//
//// MARK: - Size
//struct Size: Codable {
//let height: Int
//let url: String
//let type: String
//let width: Int
//}
