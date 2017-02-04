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
    @objc optional func didStartPlaying(my_voiceRecorder: MYVoiceRecorder)
    @objc optional func didFinishingPlaying(my_voiceRecorder: MYVoiceRecorder)
}

class MYVoiceRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    static let shareInstance = MYVoiceRecorder()
    
    fileprivate var recorderURL:URL
    
    fileprivate var session: AVAudioSession?
    fileprivate var player: AVAudioPlayer?
    
    fileprivate lazy var recorder: AVAudioRecorder? = {
        let settings = [AVFormatIDKey:NSNumber(value: kAudioFormatLinearPCM as UInt32),
                        AVSampleRateKey:NSNumber(value: 8000 as Double),
                        AVNumberOfChannelsKey:NSNumber(value: 1 as Int32),
                        AVEncoderBitDepthHintKey:NSNumber(value: 16 as Int32),
                        AVEncoderAudioQualityKey:NSNumber(value: AVAudioQuality.high.rawValue as Int)]
        do {
            let recorder = try AVAudioRecorder(url: self.recorderURL, settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            return recorder
        }catch {
            print(error)
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
    
    init(recorderURL: URL?=nil) {
        if recorderURL == nil {
            self.recorderURL = URL(fileURLWithPath: NSTemporaryDirectory() + "record.wav")
        }else {
            self.recorderURL = recorderURL!
        }
        super.init()
        assert(self.recorder != nil, "self.record should not be nil")
    }
    
    func startRecording() {
        
        self.stopPlaying()
        self.destructionRecordingFile()
        
        self.session = AVAudioSession.sharedInstance()
        
        do {
            try self.session?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.session?.setActive(true)
            self.recorder!.record()
            self.startDisplayLink()
        }catch {
            print(error)
        }
    }
    
    func stopRecording() {
        if self.recorder!.isRecording {
            self.recorder!.stop()
            self.stopDisplayLink()
        }
    }
    
    func playWithUrl(_ url:URL) -> Bool {
        var flag: Bool = true
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.delegate = self
            try self.session?.setCategory(AVAudioSessionCategoryPlayback)
            self.player?.play()
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
            try self.session?.setCategory(AVAudioSessionCategoryPlayback)
            self.player?.play()
        }catch {
            print("playWithData:\(error)")
        }
    }
    
    func stopPlaying() {
        self.player?.stop()
    }
    
    func startDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(MYVoiceRecorder.monitorVolume))
    }
    
    func stopDisplayLink() {
        self.displayLink = nil
    }
    
    func saveRecordingWithName(_ name: String , success: (_ name: String, _ fileURL: URL, _ fileUrlOfWav: URL)-> Void) {
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
        let fileName = "\(name)-\(Int(timeStamp)).amr"
        
        let docsDir = self.documentsDirectory()
        let destPath = docsDir + "/" + fileName
        
        let destURL = URL(fileURLWithPath: destPath)
        
        let fileNameOfWav = "\(name)-\(Int(timeStamp)).wav"
        
        let destPathOfWav = docsDir + "/" + fileNameOfWav
        
        let destURLOfWav = URL(fileURLWithPath: destPathOfWav)
        
        let flag = TSVoiceConverter.convertWavToAmr(self.recorderURL.absoluteString, amrSavePath: destPath)
        
        print("格式转换：\(flag)")
        
        do {
            try FileManager.default.copyItem(at: self.recorder!.url, to: destURLOfWav)
            success(fileName, destURL, destURLOfWav)
            self.recorder!.prepareToRecord()
        }catch {
            print(error)
        }
    }
    
    func destructionRecordingFile() {
        let fileManager = FileManager.default
        if fileManager.isExecutableFile(atPath: self.recorderURL.absoluteString) {
            do {
                try fileManager.removeItem(at: self.recorderURL)
            }catch {
                print(error)
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths.first!
    }
    
    func monitorVolume() {
        self.recorder!.updateMeters()
        let lowPassResults = pow(10, (0.05 * self.recorder!.peakPower(forChannel: 0)))
        let result = 10 * lowPassResults
        self.delegate?.didStartRecoring?(my_voiceRecorder: self, volume: result,currentTime: self.recorder!.currentTime)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            do {
                try self.session?.setActive(false)
            }catch {
                print(error)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.didFinishingPlaying?(my_voiceRecorder: self)
    }
}
