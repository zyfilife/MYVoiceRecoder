//
//  SlideInPresentationController.swift
//  SmartCloud
//
//  Created by 朱益锋 on 2017/1/14.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    
    fileprivate var maskView: UIView!
    private var direction: PrensentaionDirection
    
    /**
     自定义弹出控制器视图宽比例，必须小于等于1.0
     */
    var customWidth: CGFloat?
    /**
     自定义弹出控制器视图高比例，必须小于等于1.0
     */
    var customHeight: CGFloat?
    
    var defaultWidthRatio: CGFloat = 2.0/3.0
    var defaultHeightRatio: CGFloat = 2.0/3.0
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = CGRect.zero
        if containerView != nil {
            frame.size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
            switch self.direction {
            case .right:
                frame.origin.x = self.customWidth != nil ? containerView!.frame.width-self.customWidth!: containerView!.frame.width*(1.0-self.defaultWidthRatio)
            case .bottom:
                frame.origin.y = self.customHeight != nil ? containerView!.frame.height-self.customHeight!: containerView!.frame.height*(1.0-self.defaultHeightRatio)
            case .center:
                frame.origin = self.customWidth != nil && self.customHeight != nil ? CGPoint(x: (containerView!.frame.width-self.customWidth!)/2, y: (containerView!.frame.height-self.customHeight!)/2): CGPoint(x: containerView!.frame.width*(1.0-self.defaultWidthRatio), y: containerView!.frame.height*(1.0-self.defaultHeightRatio))
            default:
                frame.origin = .zero
            }
        }
        return frame
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: PrensentaionDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.setupUIWithMaskView()
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(self.maskView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskView]|", options: [], metrics: nil, views: ["maskView" : self.maskView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[maskView]|", options: [], metrics: nil, views: ["maskView" : self.maskView]))
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.maskView.alpha = 1.0
            return
        }
        coordinator.animate(alongsideTransition: { (_) in
            self.maskView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.maskView.alpha = 0.0
            return
        }
        coordinator.animate(alongsideTransition: { (_) in
            self.maskView.alpha = 0.0
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch self.direction {
        case .left, .right:
            return self.customWidth != nil ? CGSize(width: self.customWidth!, height: parentSize.height): CGSize(width: parentSize.width*self.defaultWidthRatio, height: parentSize.height)
        case .top, .bottom:
            return self.customHeight != nil ? CGSize(width: parentSize.width, height: customHeight!): CGSize(width: parentSize.width, height: parentSize.height*self.defaultHeightRatio)
        case .center:
            return self.customWidth != nil && self.customHeight != nil ? CGSize(width: self.customWidth!, height: self.customHeight!): CGSize(width: parentSize.width*self.defaultWidthRatio, height: parentSize.height*self.defaultHeightRatio)
        }
    }
}

extension SlideInPresentationController {
    fileprivate func setupUIWithMaskView() {
        self.maskView = UIView()
        self.maskView.translatesAutoresizingMaskIntoConstraints = false
        self.maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.maskView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SlideInPresentationController.clickMaskViewAction(_:)))
        self.maskView.addGestureRecognizer(tap)
    }
    
    dynamic func clickMaskViewAction(_ tap: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
