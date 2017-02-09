//
//  CollectionViewCell.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/9.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var item: VoiceModel? = nil {
        didSet {
            guard let voiceModel = self.item else {
                return
            }
            self.label.text = voiceModel.timeLength
        }
    }
    
    var timer: Timer?
    var i = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2
        self.imageView.layer.masksToBounds = true
        
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    
    func startAnimation() {
        self.stopAnimation()
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(CollectionViewCell.changeVoiceImageView), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    func changeVoiceImageView() {
        self.imageView.image = UIImage(named: "语音\(self.i)")
        
        self.i += 1
        if self.i > 2 {
            self.i = 0
        }
    }
    
    func stopAnimation() {
        self.timer?.invalidate()
        self.timer = nil
        self.i = 0
        self.imageView.image = UIImage(named: "语音2")
    }
    
}
