//
//  RealmService.swift
//  VK_client
//
//  Created by Зинде Иван on 8/20/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import RealmSwift

//Протокол для классов записи/чтения в/из Realm
protocol Itemable : Object{
    
}

//Клас для работы с Realm
class RealmService {
    
    //Метод получения данных с фильтром
    func loadFromRealm<T: Itemable>(type: T.Type, filter: NSPredicate?)-> Array<Itemable>?{
        
        do {
            let realm = try Realm()
            if filter == nil {
                let realmResults = realm.objects(type)
                return Array(realmResults)
            }
            else {
                let realmResults = realm.objects(type).filter(filter!)
                return Array(realmResults)
            }
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    //Метод записи объектов в Realm
    func saveInRealm<T: Itemable>(array: [T]){
        
        do {
            let realm = try Realm()
            realm.beginWrite()
            for arrayElement in array {
                realm.add(arrayElement, update: .modified)
            }
            do {
                try realm.commitWrite()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}
