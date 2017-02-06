//
//  SlideInPrensentationDelegate.swift
//  SmartCloud
//
//  Created by 朱益锋 on 2017/1/14.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

enum PrensentaionDirection: Int {
    case left=0
    case top
    case right
    case bottom
    case center
}

class SlideInPrensentationDelegate: NSObject {
    
    var direction = PrensentaionDirection.left
    var disableCompactHeight = true
    
    var customWidth: CGFloat?
    var customHeight: CGFloat?
}

extension SlideInPrensentationDelegate: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: self.direction)
        presentationController.customWidth = self.customWidth
        presentationController.customHeight = self.customHeight
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SliderPresentationAnimator(direction: direction, isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SliderPresentationAnimator(direction: direction, isPresentation: false)
    }
}

extension SlideInPrensentationDelegate: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && self.disableCompactHeight {
            return .overFullScreen
        }else {
            return .none
        }
    }
}
