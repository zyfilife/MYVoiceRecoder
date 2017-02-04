//
//  ViewController.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/4.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = MYVoiceRecorder.shareInstance
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

