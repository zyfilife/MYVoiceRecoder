//
//  TSVoiceConverter.swift
//  TSVoiceConverter
//
//  Created by Hilen on 1/5/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import Foundation

open class TSVoiceConverter {
    /**
    Convert AMR file to WAV file

     - parameter amrFilePath: Your AMR file path
     - parameter wavSavePath: Your WAV save path
 
     - returns: Convert success?
    */
    open static func convertAmrToWav(_ amrFilePath: String, wavSavePath: String) -> Bool {
        guard let amrCString = amrFilePath.cString(using: String.Encoding.utf8) else { return false }
        guard let wavCString = wavSavePath.cString(using: String.Encoding.utf8) else { return false }
        let decode = DecodeAMRFileToWAVEFile(amrCString, wavCString)
        return Bool(decode)
    }

    /** 
    Convert WAV file to AMR file
 
     - parameter wavSavePath: Your WAV file path
     - parameter amrFilePath: Your AMR save path

     - returns: Convert success?
    */
    open static func convertWavToAmr(_ wavFilePath: String, amrSavePath: String) -> Bool {
        guard let wavCString = wavFilePath.cString(using: String.Encoding.utf8) else { return false }
        guard let amrCString = amrSavePath.cString(using: String.Encoding.utf8) else { return false }
        let encode = EncodeWAVEFileToAMRFile(wavCString, amrCString, 1, 16)
        return Bool(encode)
    }

    /**
    Detect whether the file is AMR type
 
     - parameter filePath: The file path
 
     - returns: True of false
    */
    open static func isAMRFile(_ filePath: String) -> Bool {
        guard let result = String.init(filePath) else { return false }
        return isAMRFile(result)
    }

    /**
    Detect whether the file is MP3 type
 
     - parameter filePath: The file path
 
     - returns: True of false
    */
    open static func isMP3File(_ filePath: String) -> Bool {
        guard let result = String.init(filePath) else { return false }
        return isMP3File(result)
    }
}


private extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}


