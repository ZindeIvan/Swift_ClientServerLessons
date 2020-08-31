//
//  FriendsPhotoCollectionViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/9/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

//Класс для отображения коллекции фото друзей пользователя
class FriendsPhotoCollectionViewController : UICollectionViewController {
    //Свойство идентификатора друга пользователя
    var friendID : Int?
    //Свойство содержащее запрос фото
    var photos : Results<Photo>?  {
        let photos: Results<Photo>? = realmService?.loadFromRealm().filter("ownerID == %i", friendID ?? 0)
        return photos?.sorted(byKeyPath: "id", ascending: true)
    }
    //Свойство количество фото для отображения
    var photoCount : Int = 3
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService.shared
    
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Вызовем загрузку фото из сети
        loadPhotosFromNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Вернем количество фото
        return photos?.count ?? 0
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsPhotoCell", for: indexPath) as! FriendsPhotoCell
        //Установим фото друга в ячейке
        cell.friendPhotoImageView.sd_setImage(with: URL(string: photos?[indexPath.row].photoSizeX ?? photos?[indexPath.row].photoSizeM ?? "error"), placeholderImage: UIImage(named: "error"))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Проверим идентификатор перехода
        if segue.identifier == "PhotoSegue" {
            //Если переход предназначен для открытия коллекции фото друга
            if let destination = segue.destination as? PhotoViewController {
                guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
                destination.setPhotoInformation(friendID: friendID, friendPhotoCount: photos?.count ?? 0, friendPhotoID: indexPath.row, photos: photos?.map { $0.photoSizeX } ?? [String]())
            }
        }
    }
    
}

//Расширение для работы с сетью
extension FriendsPhotoCollectionViewController {
    //Метод загрузки фото из сети
    func loadPhotosFromNetwork(){
        networkService.loadPhotos(token: Session.instance.token, ownerID: friendID ?? 0, albumID: .profile, photoCount: photoCount){ [weak self] result in
            switch result {
            case let .success(photos):
                DispatchQueue.main.async {
                    try? self?.realmService?.saveInRealm(objects: photos)
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
}

