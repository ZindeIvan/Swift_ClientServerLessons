//
//  Animator.swift
//  VK_client
//
//  Created by Зинде Иван on 8/2/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс аниматор для появления экрана
class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //Метод длительности анимации
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    //Метод анимации перехода
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Текущий экран
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        //Экран назначения
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        //Добавим экран назначения
        transitionContext.containerView.addSubview(destination.view)
        //Зададим границы экрана назначения
        destination.view.frame = source.view.frame
        //Спрячем экран назначения
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let transform = CGAffineTransform(translationX: source.view.frame.width, y: 0)
        destination.view.transform = scale.concatenating(transform)
        
        //Зададим анимацию перехода
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .calculationModePaced,
            animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    
                    let transform = CGAffineTransform(translationX: -source.view.frame.width, y: 0)
                    let scale =  CGAffineTransform(scaleX: 0.5, y: 0.5)
                    
                    source.view.transform = scale.concatenating(transform)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    destination.view.transform = .identity
                }
                
        }) { result in
            if result && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
                transitionContext.completeTransition(true)
            }
            else {
                transitionContext.completeTransition(false)
            }
        }
    }
}

//Класс аниматор для исчезновения экрана
class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //Метод длительности анимации
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    //Метод анимации перехода
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Текущий экран
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        //Экран назначения
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        //Добавим экран назначения
        transitionContext.containerView.addSubview(destination.view)
        transitionContext.containerView.sendSubviewToBack(destination.view)
        //Зададим границы экрана назначения
        destination.view.frame = source.view.frame
        //Спрячем экран назначения
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let transform = CGAffineTransform(translationX: -source.view.frame.width, y: 0)
        destination.view.transform = scale.concatenating(transform)
        //Зададим анимацию перехода
        UIView.animateKeyframes(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            options: .calculationModePaced,
            animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    
                    let transform = CGAffineTransform(translationX: source.view.frame.width, y: 0)
                    let scale =  CGAffineTransform(scaleX: 0.5, y: 0.5)
                    
                    source.view.transform = scale.concatenating(transform)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    destination.view.transform = .identity
                }
                
                
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
}

//Класс интерактивного перехода экранов
class InteractiveTransition: UIPercentDrivenInteractiveTransition {
    //Переменная старта анимации
    var hasStarted: Bool = false
    //Переменная должна ли анимация закончится
    var shouldFinish: Bool = false
    //Экран
    var viewController: UIViewController? {
        didSet {
            //Добавим инспектор события свайпа края экрана
            let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            recognizer.edges = [.left]
            viewController?.view.addGestureRecognizer(recognizer)
        }
    }
    //Метод обработки свайпа
    @objc func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            hasStarted = true
            viewController?.navigationController?.popViewController(animated: true)
            
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            let relativeTranslation = translation.x / (gesture.view?.bounds.width ?? 1)
            let progress = max(0, min(1, relativeTranslation))
            //Если прошли 1/3 экрана - то завершим анимацию
            shouldFinish = progress > 0.33
            
            update(progress)
            
        case .ended:
            hasStarted = false
            shouldFinish ? finish() : cancel()
            
        case .cancelled:
            hasStarted = false
            cancel()
        default:
            return
        }
    }
}
