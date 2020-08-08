//
//  LikeControlView.swift
//  VK_client
//
//  Created by Зинде Иван on 7/12/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс элемента-лайка для фото
class LikeControlView : UIControl {
    //Зададим свойство количество уже установленных лайков произвольным образом
    var likeCount : Int = Int.random(in: 0 ..< 100) {
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
            UIView.transition(with: self.likeCountLabel,
                              duration: 0.5,
                              options: animationType,
                              animations: {
                                self.likeCountLabel.text = String(self.likeCount)
            })
            
        }
    }
    //Лайк отмечен
    var likeIsSelected : Bool = false{
        didSet {
            //Обновим представление элемента
            updateLikes()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    //Элемент надписи количества
    private var likeCountLabel : UILabel!
    //Элемент кнопки лайка
    private var likeButton : UIButton!
    //Элемент группировки
    private var stackView : UIStackView!
    
    //Цвет отмеченного лайка
    private let selectedColor : UIColor = .red
    //Цвет не активного лайка
    private let diselectedColor : UIColor = .black
    
    //Метод установки элементов
    private func setupView() {
        //Уберем цвет фона элемента
        self.backgroundColor = .clear
        //Создадим кнопку
        likeButton = UIButton(type: .system)
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.addTarget(self,
                             action:
                                #selector(likePressed(_:)),
                             for: .touchUpInside)
        likeButton.backgroundColor = .clear
        likeButton.tintColor = diselectedColor
        
        //Создадим надпись количества лайков
        likeCountLabel = UILabel()
        likeCountLabel.text = String(likeCount)
        likeCountLabel.textColor = diselectedColor
        
        //Создадим элемент группировки добавим на него элементы и настроим
        stackView = UIStackView()
        stackView.addArrangedSubview(likeCountLabel)
        stackView.addArrangedSubview(likeButton)
        
        stackView.spacing = 1
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        //Добавляем на текущий View программно созданные элементы
        addSubview(stackView)
        
    }
    //Обработчик нажатия кнопки лайка
    @objc func likePressed( _ button : UIButton){
        //Изменим состояние лайка
        likeIsSelected = !likeIsSelected
    }
    
    //Метод обновления визуальных элементов лайка
    private func updateLikes (){
        //Если лайк нажат
        if likeIsSelected {
            //Увеличим количество лайков на 1
            likeCount += 1
            //Установим картинку заполненного сердца
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            //Изменим цвет элементов
            likeCountLabel.textColor = selectedColor
            likeButton.tintColor = selectedColor
        }
        //Если лайк отжат
        else {
            //Уменьшим количество лайков на 1
            likeCount -= 1
            //Установим картинку пустого сердца
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            //Изменим цвет элементов
            likeCountLabel.textColor = diselectedColor
            likeButton.tintColor = diselectedColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Установи границы группировочного элемента
        stackView.frame = bounds
    }
}
