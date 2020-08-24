//
//  FriendsPhotoCollectionViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/9/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс для отображения коллекции фото друзей пользователя
class FriendsPhotoCollectionViewController : UICollectionViewController {
    //Свойство идентификатора друга пользователя
    var friendID : String?
    //Свойство массива ссылок на фото
    var photos : [String] = []
    //Свойство количество фото для отображения
    var photoCount : Int = 3
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService()
    
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Вызовем загрузку фото из сети
        loadPhotosFromNetwork()
        //Загрузим список фото друга из Realm
        loadPhotosFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPhotosFromRealm()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Вернем количество фото
        return photos.count
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsPhotoCell", for: indexPath) as! FriendsPhotoCell
        //Установим фото друга в ячейке
        cell.friendPhotoImageView.sd_setImage(with: URL(string: photos[indexPath.row]), placeholderImage: UIImage(named: "error"))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Проверим идентификатор перехода
        if segue.identifier == "PhotoSegue" {
            //Если переход предназначен для открытия коллекции фото друга
            if let destination = segue.destination as? PhotoViewController {
                
                guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }

                destination.setPhotoInformation(friendID: friendID, friendPhotoCount: photos.count, friendPhotoID: indexPath.row, photos: photos)
            }
        }
    }
    
}

//Расширение для работы с сетью
extension FriendsPhotoCollectionViewController {
    //Метод загрузки фото из сети
    func loadPhotosFromNetwork(){
        networkService.loadPhotos(token: Session.instance.token, ownerID: Int(friendID!) ?? 0, albumID: .profile, photoCount: photoCount){ [weak self] result in
            switch result {
            case let .success(photos):
                self?.realmService.saveInRealm(array: photos)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
}

//Расширение для работы с Realm
extension FriendsPhotoCollectionViewController{
     
    //Метод загрузки списка фото друга из Realm
    func loadPhotosFromRealm(){
        let searchPredicate = NSPredicate(format: "ownerID == %i", Int(friendID!) ?? 0)
        guard let photoResults = realmService.loadFromRealm(type: PhotoItem.self, filter: searchPredicate) else {return}
        setPhotosFromPhotosItems(photoResults as! [PhotoItem])
        collectionView.reloadData()
    }
    
    func setPhotosFromPhotosItems(_ photos: [PhotoItem]){
        self.photos = []
        for photo in photos {
            self.photos.append(photo.photoSizeX)
        }
    }
    
}
