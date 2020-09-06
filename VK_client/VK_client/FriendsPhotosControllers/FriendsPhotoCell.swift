//
//  FriendsPhotoCell.swift
//  VK_client
//
//  Created by Зинде Иван on 7/9/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс ячейки коллекции фото друзей пользователя
class FriendsPhotoCell : UICollectionViewCell {
    //Элемент фото
    @IBOutlet weak var friendPhotoImageView : UIImageView!
    //Элемент отметки Нравится
    @IBOutlet weak var friendPhotoLikeControlView : LikeControlView!
}
