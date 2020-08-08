//
//  GroupsSearchTableCell.swift
//  VK_client
//
//  Created by Зинде Иван on 7/10/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс ячейки списка доступных групп пользователя
class GroupsSearchTableCell : UITableViewCell {
    //Иконка группы
    @IBOutlet weak var groupSearchIconView : UIImageView!
    //Название группы
    @IBOutlet weak var groupSearchNameLabel : UILabel!
    //Привяка высоты иконки
    @IBOutlet weak var groupSearchIconHeightConstraint: NSLayoutConstraint!
    //Привязка ширины иконки
    @IBOutlet weak var groupSearchIconWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Зарегистрируем обработчик нажатия на иконку
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconImageTapped(tapGestureRecognizer:)))
        groupSearchIconView.isUserInteractionEnabled = true
        groupSearchIconView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //Метод обработки нажатия на иконку
    @objc func iconImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //Запомним данные привязок
        let groupSearchIconHeightConstraintConstant = self.groupSearchIconHeightConstraint.constant
        let groupSearchIconWidthConstraintConstant = self.groupSearchIconWidthConstraint.constant
        //Зададим коэффициент сжатия
        let resizeConstant : CGFloat = 1.08
        //Зададим пружинную анимацию
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
                        //Изменяем привязки
                        self.groupSearchIconHeightConstraint.constant = self.groupSearchIconHeightConstraint.constant / resizeConstant
                        self.groupSearchIconWidthConstraint.constant = self.groupSearchIconWidthConstraint.constant / resizeConstant
                        self.layoutIfNeeded()
        }) {(result) in
            //Возвращаем значение привязок
            UIView.animate(withDuration: 0.4) {
                self.groupSearchIconHeightConstraint.constant = groupSearchIconHeightConstraintConstant
                self.groupSearchIconWidthConstraint.constant = groupSearchIconWidthConstraintConstant
            }
            
        }
    }
}

