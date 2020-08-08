//
//  Session.swift
//  VK_client
//
//  Created by Зинде Иван on 8/8/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Класс имплементирующий паттерн Одиночка для записи данных сессии
class Session {
    
    static let instance = Session()
    
    private init(){
        
    }
    
    var token : String = ""
    var userID : Int = 0
    
}
