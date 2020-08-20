//
//  NetworkService.swift
//  VK_client
//
//  Created by Зинде Иван on 8/12/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import Foundation
import Alamofire
//import RealmSwift

//Класс для работы с сетевыми запросами
class NetworkService {
    //Свойство основной ссылки на API
    private let baseURL : String = "https://api.vk.com"
    //Свойство версии API
    private let apiVersion : String = "5.122"
    //Свойство методов доступа к данным
    private var method : Methods?
    
    static let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //Перечисление методов доступа
    enum Methods : String{
        case groups = "groups.get"
        case frinds = "friends.get"
        case photos = "photos.get"
        case groupsSearch = "groups.search"
    }
    
    //Перечисление типов альбомов фото пользователей
    enum AlbumID : String {
        case wall = "wall"
        case profile = "profile"
        case saved = "saved"
    }
    
    //Метод формирования сетевого запроса и вывода результата в кансоль
    private func networkRequest( URL : String, method : HTTPMethod, parameters : Parameters, completion: ((Result<[Any], Error>) -> Void)? = nil){
        
        AF.request(URL, method: method, parameters: parameters).responseData { response in
            
            switch response.result {
                
            case .success(let data):

                switch self.method {
                //Случай когда вызван метод запроса друзей
                case .frinds:
                    do {
                        let users = try JSONDecoder().decode(UserQuery.self, from: data).response.items
                        
                        completion?(.success(users))
                    } catch {
                        completion?(.failure(error))
                    }
                //Случай когда вызван метод запроса групп
                case .groups, .groupsSearch:
                    do {
                        let users = try JSONDecoder().decode(GroupQuery.self, from: data).response.items
                        completion?(.success(users))
                    } catch {
                        completion?(.failure(error))
                    }
                //Случай когда вызван метод запроса фото
                case .photos:
                    do {
                        let photos = try JSONDecoder().decode(PhotoQuery.self, from: data).response.items
                        completion?(.success(photos))
                    } catch {
                        completion?(.failure(error))
                    }
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
        
        networkRequest( URL: baseURL + path, method: .get, parameters: params) { result in
            
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
        
        networkRequest( URL: baseURL + path, method: .get, parameters: params){ result in
            
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
        
        networkRequest( URL: baseURL + path, method: .get, parameters: params){ result in
            
            
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
    func loadPhotos(token: String, ownerID : Int, albumID : AlbumID, photoCount : Int,completion: ((Result<[PhotoItem], Error>) -> Void)? = nil) {
        method = .photos
        let path = "/method/" + method!.rawValue
        
        let params: Parameters = [
            "access_token": token,
            "owner_id" : ownerID,
            "album_id": albumID.rawValue,
            "rev" : 1,
            "offset" : 0,
            "count" : photoCount,
            "v": apiVersion
        ]
        
        networkRequest( URL: baseURL + path, method: .get, parameters: params){ result in
            
            switch result {
            case let .success(photos):
                completion?(.success(photos as! [PhotoItem]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
}

