//
//  BaseViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 9/2/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit
//Класс стандартный экран с оповещением
class BaseViewController : UIViewController {
    //Метод отображения оповещения
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
