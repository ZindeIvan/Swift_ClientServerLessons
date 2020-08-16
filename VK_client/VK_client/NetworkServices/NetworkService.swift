//
//  NetworkService.swift
//  VK_client
//
//  Created by Зинде Иван on 8/12/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import Alamofire

enum Methods : String{
    case groups = "groups.get"
    case frinds = "friends.get"
    case photos = "photos.get"
    case groupsSearch = "groups.search"
}

//Класс для работы с сетевыми запросами
class NetworkService {
    
    private let baseURL : String = "https://api.vk.com"
    private let apiVersion : String = "5.122"
    private var method : Methods?
    
    static let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //Метод формирования сетевого запроса и вывода результата в кансоль
    private func networkRequest(URL : String, method : HTTPMethod, parameters : Parameters, completion: ((Result<[Any], Error>) -> Void)? = nil){
        
        AF.request(URL, method: method, parameters: parameters).responseData { response in
            
            switch response.result {
                
            case .success(let data):
                
                switch self.method {
                    
                case .frinds:
                    do {
                        let users = try JSONDecoder().decode(UserQuery.self, from: data).response.items
                        completion?(.success(users))
                    } catch {
                        print(error)
                    }
                case .groups, .groupsSearch:
                    do {
                        let users = try JSONDecoder().decode(GroupQuery.self, from: data).response.items
                        completion?(.success(users))
                    } catch {
                        print(error)
                    }
                case .photos:
                    print("")
                case .none:
                    return
                }
            case .failure(let error):
                completion?(.failure(error))
            }
            
        }
    }
    
    //Метод загрузки друзей пользователя
    func loadFriends(token: String, completion: ((Result<[UserItem], Error>) -> Void)? = nil){
        method = .frinds
        let path = "/method/" + method!.rawValue
        
        let params: Parameters = [
            "access_token": token,
            "order": "name",
            "count" : 20,
            "offset" : 0,
            "fields" : "city",
            "v": apiVersion
        ]
        
        networkRequest(URL: baseURL + path, method: .get, parameters: params) { result in

            switch result {
            case let .success(users):
                completion?(.success(users as! [UserItem]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
    //Метод загрузки групп пользователя
    func loadGroups(token: String, completion: ((Result<[GroupItem], Error>) -> Void)? = nil){
        method = .groups
        let path = "/method/" + method!.rawValue
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "count" : 10,
            "v": apiVersion
        ]
        
        networkRequest(URL: baseURL + path, method: .get, parameters: params){ result in

            switch result {
            case let .success(groups):
                completion?(.success(groups as! [GroupItem]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }

    }
    
    //Метод поиска групп
    func groupsSearch(token: String, searchQuery : String?, completion: ((Result<[GroupItem], Error>) -> Void)? = nil){
        method = .groupsSearch
        let path = "/method/" + method!.rawValue
        
        let params: Parameters = [
            "access_token": token,
            "q": searchQuery ?? "",
            "sort" : 2,
            "offset" : 0,
            "count" : 20,
            "v": apiVersion
        ]
        
        networkRequest(URL: baseURL + path, method: .get, parameters: params){ result in

            switch result {
            case let .success(groups):
                completion?(.success(groups as! [GroupItem]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
    //Метод загрузки фото пользователя
    func loadPhotos(token: String) {
        method = .photos
        let path = "/method/" + method!.rawValue
        
        let params: Parameters = [
            "access_token": token,
            "album_id": "profile",
            "rev" : 0,
            "offset" : 0,
            "count" : 3,
            "v": apiVersion
        ]
        
        networkRequest(URL: baseURL + path, method: .get, parameters: params)
        
    }
    

}

