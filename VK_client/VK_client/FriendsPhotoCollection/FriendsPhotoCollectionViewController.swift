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
class FriendsPhotoCollectionViewController : UICollectionViewController{
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
    //Свойство - токен для наблюдения за изменениями данных в Realm
    private var photosNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Установим оповещения
        setNotifications()
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
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
}

//Методы работы с оповещениями Realm
extension FriendsPhotoCollectionViewController {

    //Метод установки оповещений
    func setNotifications(){
        //Установим наблюдателя для событий с данными в БД
        photosNotificationToken = photos?.observe { [weak self] change in
            switch change {
            //Инициализация
            case .initial:
                #if DEBUG
                print("Initialized")
                #endif
            //Изменение
            case let .update(results, deletions: deletions, insertions: insertions, modifications: modifications):
                #if DEBUG
                print("""
                    New count: \(results.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                #endif
                
                self?.collectionView.performBatchUpdates({
                    //Удаление элементов
                    self?.collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    //Добавление элементов
                    self?.collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    //Обновление элементов
                    self?.collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                })

            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
    }
    
    //Метод вызова оповещений об ошибках
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   handler: ((UIAlertAction) -> ())? = nil,
                   completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: completion)
    }
}


