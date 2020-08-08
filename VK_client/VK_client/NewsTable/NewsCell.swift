//
//  NewsCell.swift
//  VK_client
//
//  Created by Зинде Иван on 7/25/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//protocol NewsCellDelegate : class {
//    func newsCell(cell: NewsCell, didTappedThe button:UIButton?)
//}

class NewsCell : UITableViewCell {
    
    @IBOutlet weak var newsIconView : UIImageView!
    @IBOutlet weak var newsOwner : UILabel!
    @IBOutlet weak var newsDate : UILabel!
    @IBOutlet weak var newsText : UILabel!
    @IBOutlet weak var newsImage : UIImageView!
    @IBOutlet weak var likeButton : UIButton!
    @IBOutlet weak var commentButton : UIButton!
    @IBOutlet weak var shareButton : UIButton!
    @IBOutlet weak var likeLabel : UILabel!
    @IBOutlet weak var watchedCountLabel : UILabel!
    
    private var likePressed : Bool = false{
        didSet {
            
            if likePressed {
                //Увеличим количество лайков на 1
                likeCount += 1
                //Установим картинку заполненного сердца
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                //Изменим цвет элементов
                likeLabel.textColor = .red
                likeButton.tintColor = .red
            }
                //Если лайк отжат
            else {
                //Уменьшим количество лайков на 1
                likeCount -= 1
                //Установим картинку пустого сердца
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                //Изменим цвет элементов
                likeLabel.textColor = .gray
                likeButton.tintColor = .gray
            }
        }
        
    }
    
    var likeCount : Int = 0{
        didSet {
            //Обновим количество лайков
            //Зададим анимацию смены текста
            let animationType : AnimationOptions
            //Если старое значение меньше - справа и слева в обратном случае
            if  oldValue < likeCount {
                animationType = .transitionFlipFromRight
            }
            else {
                animationType = .transitionFlipFromLeft
            }
            //Зададим анимацию смены текста
            UIView.transition(with: self.likeLabel,
                              duration: 0.5,
                              options: animationType,
                              animations: {
                                self.likeLabel.text = String(self.likeCount)
            })
        }
    }
    //Метод нажатия лайка
    @IBAction func likeButtonPressed(_ sender: Any) {
        likePressed = !likePressed
    }
    
}
