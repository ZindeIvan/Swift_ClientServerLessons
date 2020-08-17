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
    
    var photos : [String] = []
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Вызовем загрузку фото из сети
        loadPhotosFromNetwork()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Вернем количество фото = 3
        return 3
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsPhotoCell", for: indexPath) as! FriendsPhotoCell
        //Установим фото друга в ячейке
        let imagePath : String = friendID == nil ? "error" : friendID! + "_photo\(indexPath.row)"
        let image : UIImage = (UIImage(named: imagePath) == nil ? UIImage(named: "error") : UIImage(named: imagePath))!
        cell.friendPhotoImageView.image = image
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Проверим идентификатор перехода
        if segue.identifier == "PhotoSegue" {
            //Если переход предназначен для открытия коллекции фото друга
            if let destination = segue.destination as? PhotoViewController {
                
                guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }

                destination.setPhotoInformation(friendID: friendID, friendPhotoCount: 3, friendPhotoID: indexPath.row)
            }
        }
    }
    
}

//Расширение для работы с сетью
extension FriendsPhotoCollectionViewController {
    //Метод загрузки фото из сети
    func loadPhotosFromNetwork(){
        networkService.loadPhotos(token: Session.instance.token, ownerID: Int(friendID!)!, albumID: .profile, photoCount: 3){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(photos):
                for photo in photos {
                    self.photos.append(photo.photoSizes["x"]!)
                }
                self.collectionView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
}
