//
//  FirebaseConfig.swift
//  VK_client
//
//  Created by Зинде Иван on 9/6/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Перечисление типов конфигураций Firebase
enum DatabaseType {
    
    case database
    case firestore
}

//Перечисление с текущим типом конфигурации Firebase
enum Config {
    
    static let databaseType: DatabaseType = .firestore
}

