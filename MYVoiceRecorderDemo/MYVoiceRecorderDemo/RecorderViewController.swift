//
//  RecorderViewController.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/6.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class RecorderViewController: UIViewController, MYVoiceRecorderDelegate {
    
    lazy var recorderHUD: MYRecorderHUD = {
        let view = Bundle.main.loadNibNamed("MYRecorderHUD", owner: self, options: nil)?.first as! MYRecorderHUD
        view.rate = 0.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        MYVoiceRecorder.shareInstance.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchDown(_ sender: UIButton) {
        MYVoiceRecorder.shareInstance.startRecording()
        self.recorderHUD.show()
    }

    @IBAction func dragOutSide(_ sender: Any) {
        MYVoiceRecorder.shareInstance.cancelRecording()
        self.recorderHUD.hide()
    }
    
    @IBAction func touchUpInside(_ sender: UIButton) {
        self.recorderHUD.hide()
        MYVoiceRecorder.shareInstance.stopRecording()
    }
    
    func didStartRecoring(my_voiceRecorder: MYVoiceRecorder, volume: Float, currentTime: TimeInterval) {
        print(volume,currentTime)
        self.recorderHUD.rate = CGFloat(volume)
    }
    
    func didFinishRecording(my_voiceRecorder: MYVoiceRecorder, wavURL: URL, amrURL: URL) {
        let _ = MYVoiceRecorder.shareInstance.playWithUrl(wavURL)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
