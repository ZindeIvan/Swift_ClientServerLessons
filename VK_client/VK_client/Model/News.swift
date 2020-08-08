//
//  News.swift
//  VK_client
//
//  Created by Зинде Иван on 7/25/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation

//Класс Новости
struct News {
    //Идентификатор новости
    let newsID : String
    //Количество просмотров
    let newsWatchedCount : Int
    //Количество отметок Нравится
    let likeCount : Int
    //Автор новости
    let newsOwner : String
    //Дата Новости
    let newsDate : String
    //Текст Новости
    let newsText : String
    
}
