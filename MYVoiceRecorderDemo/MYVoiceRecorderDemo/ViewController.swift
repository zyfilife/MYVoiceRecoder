//
//  ViewController.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/4.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var direction = PrensentaionDirection.bottom
    
    let slideInPrensentationDelegate = SlideInPrensentationDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = MYVoiceRecorder.shareInstance
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueViewToRecorderView" {
            let viewController = segue.destination
            self.slideInPrensentationDelegate.direction = self.direction
            self.slideInPrensentationDelegate.customHeight = 50
            self.slideInPrensentationDelegate.disableCompactHeight = true
            viewController.transitioningDelegate = self.slideInPrensentationDelegate
            viewController.modalPresentationStyle = .custom
        }
    }
}

