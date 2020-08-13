//
//  NetworkService.swift
//  VK_client
//
//  Created by Зинде Иван on 8/12/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import Alamofire

//Класс для работы с сетевыми запросами
class NetworkService {
    
    static let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //Метод формирования сетевого запроса и вывода результата в кансоль
    private func networkRequest(URL : String, method : HTTPMethod, parametrs : Parameters){
        NetworkService.session.request(URL, method: method, parameters: parametrs).responseJSON { response in
            guard let json = response.value else { return }
            
            print(json)
        }
    }
    
    //Метод загрузки групп пользователя
    func loadGroups(token: String) {
        let baseUrl = "https://api.vk.com"
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "count" : 3,
            "v": "5.92"
        ]
        
        networkRequest(URL: baseUrl + path, method: .get, parametrs: params)
        
    }
    
    //Метод загрузки друзей пользователя
    func loadFriends(token: String) {
        let baseUrl = "https://api.vk.com"
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": token,
            "order": "name",
            "count" : 3,
            "offset" : 0,
            "fields" : "city",
            "v": "5.92"
        ]
        
        networkRequest(URL: baseUrl + path, method: .get, parametrs: params)
        
    }
    
    //Метод загрузки фото пользователя
    func loadPhotos(token: String) {
        let baseUrl = "https://api.vk.com"
        let path = "/method/photos.get"
        
        let params: Parameters = [
            "access_token": token,
            "album_id": "profile",
            "rev" : 0,
            "offset" : 0,
            "count" : 3,
            "v": "5.92"
        ]

       networkRequest(URL: baseUrl + path, method: .get, parametrs: params)
        
    }
    
    //Метод поиска групп
    func groupsSearch(token: String) {
        let baseUrl = "https://api.vk.com"
        let path = "/method/groups.search"
        
        let params: Parameters = [
            "access_token": token,
            "q": "Games",
            "sort" : 2,
            "offset" : 0,
            "count" : 3,
            "v": "5.92"
        ]

       networkRequest(URL: baseUrl + path, method: .get, parametrs: params)
        
    }
}
