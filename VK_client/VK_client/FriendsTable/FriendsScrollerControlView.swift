//
//  FriendsScrollerControlView.swift
//  VK_client
//
//  Created by Зинде Иван on 7/21/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Протокол делегирования метода прокрутки
protocol FriendsScrollerControlViewDelegate : class {
    func scrollFriends(letter : Character)
}

//Класс элемента прокрутки для списка друзей
class FriendsScrollerControlView : UIControl {
    
    //Элемент группировки
    private var stackView : UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //Массив кнопок
    private var buttons: [UIButton] = []
    
    //Массив букв для кнопок
    private var lettersArray : [Character] = []
    
    weak var delegate : FriendsScrollerControlViewDelegate?
    
    //Метод заполнения массива букв
    func setLetters (letters : [Character]) {
        lettersArray = []
        for letter in letters {
            lettersArray.append(letter)
        }
    }
    
    //Метод установки элементов
    func setupScrollerView() {
        
        clearButtons()
        //Обходим массив букв и устанавливаем для каждой буквы свою кнопку
        for letter in lettersArray {
            let button = UIButton(type: .system)
            button.setTitle(String(letter).uppercased(), for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .selected)
            
            button.addTarget(self,
                             action: #selector(lettreSelected(_:)),
                             for: .touchUpInside)
            
            buttons.append(button)
        }
        //Разместим кнопки на элементе группировки
        stackView = UIStackView(arrangedSubviews: buttons)
        //Настроим элемент группировки
        stackView.spacing = 1
        stackView.axis = .vertical
        
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        //Добавляем на текущий View программно созданные элементы
        addSubview(stackView)
    }
    
    //Обработчик нажатия буквы
    @objc func lettreSelected( _ button : UIButton){
        guard let index = buttons.firstIndex(of: button) else { return }
        let letter = lettersArray[index]
        delegate?.scrollFriends(letter : letter)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Установи границы группировочного элемента
        stackView.frame = bounds
    }
    
    func clearButtons(){
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = []
    }
}
