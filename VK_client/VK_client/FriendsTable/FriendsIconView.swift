//
//  FriendsIconView.swift
//  VK_client
//
//  Created by Зинде Иван on 7/11/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Настраиваемый Класс для отображения тени под иконкой аватарки друга
class IconShadowView : UIView {
    
    override class var layerClass: AnyClass{
        return CAShapeLayer.self
    }
    
    //Цвет тени
    var shadowColor : UIColor = .black {
        didSet{
            updateShadowColor()
        }
    }
    
    //Прозрачность тени
    var shadowOpacity : Float = 0.8 {
        didSet {
            updateShadowOpasity()
        }
    }
    
    //Радиус(размер) тени
    var shadowRadius : CGFloat = 6 {
        didSet {
            updateShadowRadius()
        }
    }
    
    //Метод обновления цвета тени
    private func updateShadowColor() {
        layer.shadowColor = shadowColor.cgColor
    }
    
    //Метод обновления прозрачности тени
    private func updateShadowOpasity() {
        layer.shadowOpacity = shadowOpacity
    }
    
    //Метод обновления радиуса тени
    private func updateShadowRadius() {
        layer.shadowRadius = shadowRadius
    }
    
    //Метод настройки уровня
    func configureLayer () {
        //Зададим скругленные края
        layer.cornerRadius = frame.height / 2
        //Зададим форму тени
        layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        //Зададим цвет тени
        layer.shadowColor = shadowColor.cgColor
        //Зададим прозрачность тени
        layer.shadowOpacity = shadowOpacity
        //Зададим радиус тени
        layer.shadowRadius = shadowRadius
        //Зададим направление тени
        layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
}

//Клас для скругления иконки аватарки друга
class IconView : UIImageView {
    
    override class var layerClass: AnyClass{
        return CAShapeLayer.self
    }
    
    func configureLayer () {
        //Зададим скругленные края
        layer.cornerRadius = frame.height / 2
        //Ограничим прорисовку контента за краями
        clipsToBounds = true
    }
}
