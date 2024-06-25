//
//  ASLFileManager.swift
//  VVTools
//
//  Created by 赵江明 on 2024/6/24.
//


import Foundation

public class ASLFileManager: SoldierFileManager {
    public static func directoryURL() -> URL? {
        let fileManager = FileManager.default
        guard let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let tempDirectoryURL = cacheURL.appendingPathComponent("com.vvtools.asl", isDirectory: true)
        if !fileManager.fileExists(atPath: tempDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }catch (let error){
                print("ASLFileManager create ASL directory error:\(error.localizedDescription)")
                return nil
            }
        }
        return tempDirectoryURL
    }
}
