//
//  MYRecorderHUD.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/6.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

@IBDesignable
class MYRecorderHUD: UIView {
    
    @IBInspectable var rate: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var fillColor: UIColor = .green {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var image: UIImage! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image = UIImage(named: "Mic")
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image = UIImage(named: "Mic")
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        image = UIImage(named: "Mic")
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
    
    func show() {
        self.rate = 0.0
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func hide() {
        self.rate = 0.0
        self.removeFromSuperview()
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: bounds.size.height)
        context?.scaleBy(x: 1, y: -1)
        
        context?.draw(image.cgImage!, in: bounds)
        context?.clip(to: bounds, mask: image.cgImage!)
        
        context?.setFillColor(fillColor.cgColor.components!)
        context?.fill(CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * rate))
    }
 
    override func prepareForInterfaceBuilder() {
        let bundle = Bundle(for: self.classForCoder)
        image = UIImage(named: "Mic", in: bundle, compatibleWith: self.traitCollection)
    }

}
