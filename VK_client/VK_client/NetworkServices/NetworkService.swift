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
    
    static let shared = NetworkService()
    
    private init(){}
    
    static let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //Перечисление типов альбомов фото пользователей
    enum AlbumID : String {
        case wall = "wall"
        case profile = "profile"
        case saved = "saved"
    }
    
    //Метод формирования сетевого запроса и вывода результата в кансоль
    private func networkRequest<T: Decodable>( type : T.Type, URL : String, method : HTTPMethod, parameters : Parameters, completion: ((Result<[Any], Error>) -> Void)? = nil){
        
        AF.request(URL, method: method, parameters: parameters).responseData { response in
            
            switch response.result {
                
            case .success(let data):
                
                do {
                    let users = try JSONDecoder().decode(ServerResponse<T>.self, from: data).response.items
                    
                    completion?(.success(users))
                } catch {
                    completion?(.failure(error))
                }
                
            case .failure(let error):
                completion?(.failure(error))
            }
            
        }
    }
    
    //Метод загрузки друзей пользователя
    func loadFriends(token: String, completion: ((Result<[User], Error>) -> Void)? = nil){
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": token,
            "order": "name",
            "count" : 20,
            "offset" : 0,
            "fields" : "photo_50",
            "v": apiVersion
        ]
        
        networkRequest( type: User.self, URL: baseURL + path, method: .get, parameters: params) { result in
            
            switch result {
            case let .success(users):
                completion?(.success(users as! [User]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
    //Метод загрузки групп пользователя
    func loadGroups(token: String, completion: ((Result<[Group], Error>) -> Void)? = nil){
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "count" : 10,
            "v": apiVersion
        ]
        
        networkRequest( type: Group.self, URL: baseURL + path, method: .get, parameters: params){ result in
            
            switch result {
            case let .success(groups):
                completion?(.success(groups as! [Group]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
    //Метод поиска групп
    func groupsSearch(token: String, searchQuery : String?, completion: ((Result<[Group], Error>) -> Void)? = nil){
        let path = "/method/groups.search"
        
        let params: Parameters = [
            "access_token": token,
            "q": searchQuery ?? "",
            "sort" : 2,
            "offset" : 0,
            "count" : 20,
            "v": apiVersion
        ]
        
        networkRequest( type: Group.self, URL: baseURL + path, method: .get, parameters: params){ result in
            
            
            switch result {
            case let .success(groups):
                completion?(.success(groups as! [Group]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
    //Метод загрузки фото пользователя
    func loadPhotos(token: String, ownerID : Int, albumID : AlbumID, photoCount : Int,completion: ((Result<[Photo], Error>) -> Void)? = nil) {
        let path = "/method/photos.get"
        
        let params: Parameters = [
            "access_token": token,
            "owner_id" : ownerID,
            "album_id": albumID.rawValue,
            "rev" : 1,
            "offset" : 0,
            "count" : photoCount,
            "v": apiVersion
        ]
        
        networkRequest( type: Photo.self, URL: baseURL + path, method: .get, parameters: params){ result in
            
            switch result {
            case let .success(photos):
                completion?(.success(photos as! [Photo]))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
            
        }
        
    }
    
}

class ServerResponse<T: Decodable> : Decodable {
    var response : Response<T>
}

class Response<T: Decodable> : Decodable {
    let count : Int = 0
    var items : [T] = []
}
