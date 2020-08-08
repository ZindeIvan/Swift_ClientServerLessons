//
//  FriendsTableCell.swift
//  VK_client
//
//  Created by Зинде Иван on 7/8/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс ячейки списка друзей пользователя
class FriendsTableCell : UITableViewCell {
    //Надпись имени друга
    @IBOutlet weak var friendNameLabel : UILabel!
    //Тень иконки аватарки друга
    @IBOutlet weak var iconShadowView : IconShadowView!
    //Округление иконки аватарки друга
    @IBOutlet weak var iconImageView : IconView!
    //Привяка высоты иконки
    @IBOutlet weak var iconImageHeightConstraint: NSLayoutConstraint!
    //Привязка ширины иконки
    @IBOutlet weak var iconImageWidthConstraint: NSLayoutConstraint!
    //Привяка высоты тени иконки
    @IBOutlet weak var iconShadowHeightConstraint: NSLayoutConstraint!
    //Привязка ширины тени иконки
    @IBOutlet weak var iconShadowWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Зарегистрируем обработчик нажатия на иконку
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconImageTapped(tapGestureRecognizer:)))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //Метод обработки нажатия на иконку
    @objc func iconImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //Запомним данные привязок
        let iconImageHeightConstraintConstant = self.iconImageHeightConstraint.constant
        let iconImageWidthConstraintConstant = self.iconImageWidthConstraint.constant
        let iconShadowHeightConstraintConstant = self.iconShadowHeightConstraint.constant
        let iconShadowWidthConstraintConstant = self.iconShadowWidthConstraint.constant
        //Зададим коэффициент сжатия
        let resizeConstant : CGFloat = 1.08
        //Зададим пружинную анимацию
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
                        self.iconImageHeightConstraint.constant = self.iconImageHeightConstraint.constant / resizeConstant
                        self.iconImageWidthConstraint.constant = self.iconImageWidthConstraint.constant / resizeConstant
                        self.iconShadowHeightConstraint.constant = self.iconShadowHeightConstraint.constant / resizeConstant
                        self.iconShadowWidthConstraint.constant = self.iconShadowWidthConstraint.constant / resizeConstant
                        self.layoutIfNeeded()
        }) {(result) in
            //Возвращаем значение привязок
            UIView.animate(withDuration: 0.4) {
                self.iconImageHeightConstraint.constant = iconImageHeightConstraintConstant
                self.iconImageWidthConstraint.constant = iconImageWidthConstraintConstant
                self.iconShadowHeightConstraint.constant = iconShadowHeightConstraintConstant
                self.iconShadowWidthConstraint.constant = iconShadowWidthConstraintConstant
            }
            
        }
    }
}
