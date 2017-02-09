//
//  MYVoiceRecorder.swift
//  MYVoiceRecorderDemo
//
//  Created by 朱益锋 on 2017/2/4.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol MYVoiceRecorderDelegate: NSObjectProtocol {
    @objc optional func didStartRecoring(my_voiceRecorder: MYVoiceRecorder, volume:Float,currentTime: TimeInterval)
    @objc optional func didFinishRecording(my_voiceRecorder: MYVoiceRecorder, wavURL: URL, amrURL: URL)
    @objc optional func didFinishPlaying(my_voiceRecorder: MYVoiceRecorder)
    @objc optional func didStartPlaying(my_voiceRecorder: MYVoiceRecorder)
}

class MYVoiceRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    static let shareInstance = MYVoiceRecorder()
    
    fileprivate var recorderPath: String!
    
    fileprivate lazy var session: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        return session
    }()
    
    fileprivate var player: AVAudioPlayer?
    
    fileprivate lazy var recorder: AVAudioRecorder? = {
        let recordSettings = [
            AVFormatIDKey : NSNumber(value: kAudioFormatLinearPCM as UInt32),
            AVSampleRateKey : 44100.0 as AnyObject,
            AVNumberOfChannelsKey : 2 as AnyObject,
            AVLinearPCMBitDepthKey : 16 as AnyObject,
            AVLinearPCMIsBigEndianKey : false as AnyObject,
            AVLinearPCMIsFloatKey : false as AnyObject,
            ]
        do {
            let recorder = try AVAudioRecorder(url: URL(fileURLWithPath: self.recorderPath), settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            return recorder
        }catch {
            print("AVAudioRecorder init failed error: \(error)")
            return nil
        }
    }()
    
    fileprivate var displayLink: CADisplayLink? = nil {
        willSet {
            if self.displayLink != nil {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
        }
    }
    
    weak var delegate: MYVoiceRecorderDelegate?
    
    override init() {
        super.init()
        
        self.recorderPath = NSTemporaryDirectory() + "MYVoiceRecorder.wav"
        
        if let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let recorderURL = url.appendingPathComponent("MYRecorder")
            
            do {
                try FileManager.default.createDirectory(at: recorderURL, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("createDirectory: \(error)")
            }
        }
    }
    
    func startRecording() {
        
        self.stopPlaying()
        
        guard let recorder = self.recorder else {
            return
        }
        
        if recorder.isRecording {
            recorder.stop()
        }
        
        recorder.prepareToRecord()
        
        do {
            try self.session.setActive(true)
            try self.session.setCategory(AVAudioSessionCategoryRecord)
            recorder.record()
            self.startDisplayLink()
        }catch {
            print("startRecording: \(error)")
        }
        
        
    }
    
    func stopRecording() {
        
        guard let recorder = self.recorder else {
            return
        }
        if recorder.isRecording {
            recorder.stop()
            self.stopDisplayLink()
        }
    }
    
    func cancelRecording() {
        
        guard let recorder = self.recorder else {
            return
        }
        if recorder.isRecording {
            recorder.stop()
            recorder.deleteRecording()
            self.stopDisplayLink()
        }
    }
    
    func playWithUrl(_ url:URL) -> Bool {
        var flag: Bool
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.delegate = self
            try self.session.setActive(true)
            try self.session.setCategory(AVAudioSessionCategoryPlayback)
            self.player?.play()
            flag = true
        }catch {
            print("palyWithURL:\(error)")
            flag = false
        }
        return flag
    }
    
    func playWithData(_ data:Data) {
        do {
            self.player = try AVAudioPlayer(data: data)
            self.player?.delegate = self
            try self.session.setActive(true)
            try self.session.setCategory(AVAudioSessionCategoryPlayback)
            self.player?.play()
        }catch {
            print("playWithData:\(error)")
        }
    }
    
    func stopPlaying() {
        guard let player = self.player else {
            return
        }
        if player.isPlaying {
            player.stop()
        }
    }
    
    fileprivate func startDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(MYVoiceRecorder.monitorVolume))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func stopDisplayLink() {
        self.displayLink = nil
    }
    
    internal func monitorVolume() {
        self.recorder!.updateMeters()
        let peakPower = pow(10, (0.05 * recorder!.peakPower(forChannel: 0)))
        self.delegate?.didStartRecoring?(my_voiceRecorder: self, volume: 10*peakPower,currentTime: self.recorder!.currentTime)
    }
    
    func finishedRecording() {
        
        self.stopRecording()
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        let url = URL(fileURLWithPath: path)
        let recorderURL = url.appendingPathComponent("MYRecorder")
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
        
        let fileName = "Demo\(Int(timeStamp)).amr"
        
        let destURLOfAMR = recorderURL.appendingPathComponent(fileName)
        
        let fileNameOfWAV = fileName.replacingOccurrences(of: "amr", with: "wav")
        
        let destURLOfWav = recorderURL.appendingPathComponent(fileNameOfWAV)
        DispatchQueue.global().async {
            let flag = TSVoiceConverter.convertWavToAmr(self.recorderPath, amrSavePath: destURLOfAMR.path)
            print("格式转换：\(flag)")
        }
        do {
            try FileManager.default.copyItem(at: self.recorder!.url, to: destURLOfWav)
            self.delegate?.didFinishRecording?(my_voiceRecorder: self, wavURL: destURLOfWav, amrURL: destURLOfAMR)
        }catch {
            print("copyItem: \(error)")
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            do {
                try self.session.setActive(false)
            }catch {
                print(error)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.didFinishPlaying?(my_voiceRecorder: self)
    }
}
