//
//  PhotoViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/31/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс для отображения фото
class PhotoViewController : UIViewController {
    
    //Текущее фото
    private let photoImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    //Следующее фото
    private let  newPhotoImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Текущее направление свайпа
    private var currentSign = 0
    
    //Процентное количество прогресса свайпа
    private var percent: CGFloat = 0
    
    //Идентификатор следующего фото
    private var newPhotoID : Int = 0
    
    //Идентификатор друга
    private var friendID : Int?
    //Количество фото друга
    private var friendPhotoCount : Int?
    //Идентификатор текущего фото
    private var friendPhotoID : Int?
    //Массив ссылок на фото
    private var photos : [String]?
    
    var interactiveAnimator: UIViewPropertyAnimator?
    
    //Метод установки данных друга
    func setPhotoInformation(friendID : Int?, friendPhotoCount : Int, friendPhotoID: Int, photos : [String]){
        self.friendID = friendID
        self.friendPhotoCount = friendPhotoCount
        self.friendPhotoID = friendPhotoID
        self.photos = photos
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Настроим ImageView
        layout(imageView: newPhotoImageView)
        layout(imageView: photoImageView)
        //Установим фото
        setImages()
        //Добавим инспектор свайпа
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        photoImageView.addGestureRecognizer(panGesture)
        
    }
    
    //Метод настройки ImageView
    private func layout(imageView: UIImageView) {
        view.addSubview(imageView)
        //Настоим привязки
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    //Метод установки изображения по индексу в ImageView
    func setImageToView(imageID: Int, imageView : UIImageView){
        //Установим изображение в ImageView
        imageView.sd_setImage(with: URL(string: photos![friendPhotoID!]), placeholderImage: UIImage(named: "error"))
    }
    
    //Метод установки изображений
    private func setImages() {
        //Установим текущее изображение
        setImageToView(imageID: friendPhotoID!, imageView: photoImageView)
        //Вычислим следующий индекс
        var nextIndex = friendPhotoID! + 1
        //Если свайп в право то изменим индекс
        if currentSign > 0 {
            nextIndex = friendPhotoID! - 1
        }
        //Если следующее по свайпу изображение существует зададим его
        if nextIndex < friendPhotoCount!, nextIndex >= 0 {
            setImageToView(imageID: nextIndex, imageView: newPhotoImageView)
        }
        
    }
    
    //Метод обнуления настроек
    private func resetImageView() {
        //Установим следующее фото прозрачным
        newPhotoImageView.alpha = 0.0
        //Уменьщим следующее изображение
        newPhotoImageView.transform = .init(scaleX: 0.8, y: 0.8)
        //Вернем текущее изображение
        photoImageView.transform = .identity
        //Установим изображения
        setImages()
        view.layoutIfNeeded()
        //Сбросим текущее направление свайпа
        currentSign = 0
        interactiveAnimator = nil
    }
    
    //Метод анимирования смены изображения
    private func initAnimator() {
        //Установим следующее фото прозрачным
        newPhotoImageView.alpha = 0.0
        //Уменьщим следующее изображение
        newPhotoImageView.transform = .init(scaleX: 0.8, y: 0.8)
        //Остановим анимацию
        interactiveAnimator?.stopAnimation(true)
        //Зададим анимацию смены фото
        interactiveAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            let width = CGFloat(self.currentSign) * self.view.frame.width
            let translationTransform = CGAffineTransform(translationX: width, y: 0)
            
            self.photoImageView.transform = translationTransform
            
            self.newPhotoImageView.alpha = 1.0
            self.newPhotoImageView.transform = .identity
        })
        
        interactiveAnimator?.startAnimation()
        interactiveAnimator?.pauseAnimation()
    }
    
    
    //Метод обработки свайпа
    @objc func onPan(_ gesture :  UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: view)
            //Вычислим количество прогресса свайпа
            percent = abs(translation.x) / view.frame.width
            let translationX = Int(translation.x)
            //Вычислим направление свайпа
            let sign = translationX == 0 ? 1 : translationX / abs(translationX)
            
            //Если аниматор не запущен и изменилось направление свайпа
            if interactiveAnimator == nil || sign != currentSign {
                interactiveAnimator?.stopAnimation(true)
                //Переустановим изображения
                resetImageView()
                interactiveAnimator = nil
                
                if ( sign > 0 && friendPhotoID! > 0 || ( sign < 0 && friendPhotoID! < friendPhotoCount! - 1 ) ) {
                    //Установим текущее направление свайпа
                    currentSign = sign
                    //Установим изображения
                    setImages()
                    //Запустим аниматор
                    initAnimator()
                }
            }
            //Установим прогресс анимации
            interactiveAnimator?.fractionComplete = abs(translation.x) / (self.view.frame.width / 2)
            
        case .ended:
            interactiveAnimator?.addCompletion({ (position) in
                self.resetImageView()
            })
            //Если прогресс свацпа меньше 1/3 экрана
            if percent < 0.33 {
                interactiveAnimator?.stopAnimation(true)
                UIView.animate(withDuration: 0.3) {
                    self.resetImageView()
                }
            }
            else {
                //Изменим идентификатор текущего фото
                friendPhotoID! += currentSign * -1
                interactiveAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }
    
}
