//
//  RecorderViewController.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/6.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class RecorderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MYVoiceRecorderDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recordButton: UIButton!
    
    lazy var recorderHUD: MYRecorderHUD = {
        let view = Bundle.main.loadNibNamed("MYRecorderHUD", owner: self, options: nil)?.first as! MYRecorderHUD
        view.rate = 0.0
        return view
    }()
    
    var arrayOfVoiceURL = [VoiceModel]()
    
    lazy var layout: UICollectionViewFlowLayout = {
        
        let itemWidth: CGFloat = 84
        let itemColumn = Int(self.view.frame.size.width/itemWidth)
        let margin = (self.view.frame.size.width - itemWidth*CGFloat(itemColumn))/(CGFloat(itemColumn)+1)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: 33)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = margin
        layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 10, right: margin)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MYVoiceRecorder.shareInstance.delegate = self
        self.collectionView.collectionViewLayout = self.layout
        
        self.recordButton.layer.cornerRadius = self.recordButton.frame.size.width/2
        self.recordButton.layer.masksToBounds = true
        
        self.recordButton.layer.borderColor = UIColor.green.cgColor
        self.recordButton.layer.borderWidth = 1.5
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
        MYVoiceRecorder.shareInstance.finishedRecording()
    }
    
    func didStartRecoring(my_voiceRecorder: MYVoiceRecorder, volume: Float, currentTime: TimeInterval) {
        self.recorderHUD.rate = CGFloat(volume)
        self.recorderHUD.time = self.string(time: currentTime)
    }
    
    func didFinishRecording(my_voiceRecorder: MYVoiceRecorder, wavURL: URL, amrURL: URL) {
        DispatchQueue.main.async {
            let voiceModel = VoiceModel()
            voiceModel.timeLength = self.recorderHUD.time
            voiceModel.url = wavURL
            self.arrayOfVoiceURL.append(voiceModel)
            self.collectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfVoiceURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        if indexPath.row < self.arrayOfVoiceURL.count {
            cell.item = self.arrayOfVoiceURL[indexPath.row]
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        MYVoiceRecorder.shareInstance.stopPlaying()
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.startAnimation()
        
        let url = self.arrayOfVoiceURL[indexPath.row].url
        let _ = MYVoiceRecorder.shareInstance.playWithUrl(url!)
        
        for item in collectionView.indexPathsForVisibleItems {
            if item != indexPath {
                let cell = collectionView.cellForItem(at: item) as! CollectionViewCell
                cell.stopAnimation()
            }
        }
    }
    
    func didFinishPlaying(my_voiceRecorder: MYVoiceRecorder) {
        let indexPath = self.collectionView.indexPathsForSelectedItems?.first
        let cell = self.collectionView.cellForItem(at: indexPath!) as! CollectionViewCell
        cell.stopAnimation()
    }

}

extension RecorderViewController {
    internal func string(time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
}

class VoiceModel {
    var url: URL!
    var timeLength: String!
}
