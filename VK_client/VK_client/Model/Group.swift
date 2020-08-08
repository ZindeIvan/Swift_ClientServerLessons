//
//  Group.swift
//  VK_client
//
//  Created by Зинде Иван on 7/10/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Класс Группы
struct Group {
    //Свойство названия группы
    let groupName : String
    //Свойство идентификатора группы
    let groupID : String
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
