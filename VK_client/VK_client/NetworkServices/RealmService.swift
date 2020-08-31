//
//  RealmService.swift
//  VK_client
//
//  Created by Зинде Иван on 8/20/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import RealmSwift

//Клас для работы с Realm
class RealmService {
    
    static let shared = RealmService()
    
    private init?() {
        let configuration = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        guard let realm = try? Realm(configuration: configuration) else { return nil }
        self.realm = realm
        
        print("Realm database file path:")
        print(realm.configuration.fileURL ?? "")
    }
    
    private let realm: Realm
    
    //Метод получения данных
    func loadFromRealm<T: Object>()-> Results<T> {
        return realm.objects(T.self)
    }

    //Метод удаления данных
    func delete<T: Object>(object: T) throws {
        try realm.write {
            realm.delete(object)
        }
    }
    
    //Метод удаления всех данных
    func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }
    
    //Метод сохранения данных
    func saveInRealm<T: Object>(object: T) throws {
        try realm.write {
            realm.add(object, update: .all)
        }
    }
    
    //Метод сохранения данных
    func saveInRealm<T: Object>(objects: [T]) throws {
        try realm.write {
            realm.add(objects, update: .all)
        }
    }
    
}
