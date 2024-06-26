//
//  SoldierFileManager.swift
//  VVTools
//
//  Created by jiaxin on 2019/8/29.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation

public protocol SoldierFileManager {
    static func saveInfo(_ info: String, fileName: String?, fileNamePrefix: String?)
    static func directoryURL() -> URL?
    static func allFiles() -> [SanboxModel]
    static func deleteAllFiles()
}

public extension SoldierFileManager {
    static func saveInfo(_ info: String, fileName: String? = nil, fileNamePrefix: String? = nil) {
        guard !info.isEmpty else {
            return
        }
        var targetFileName: String?
        if fileName != nil {
            targetFileName = fileName
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if fileNamePrefix != nil {
                targetFileName = "\(fileNamePrefix!)-\(dateString)"
            } else {
                targetFileName = dateString
            }
        }

        guard let fileURL = directoryURL()?.appendingPathComponent("\(targetFileName!).txt") else {
            return
        }
        do {
            try info.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("write info error:\(error.localizedDescription)")
        }
    }

    /// write content to the current log file.
    static func saveInfos(_ infos: [String], fileName: String? = nil, fileNamePrefix: String? = nil) {
        guard infos.isEmpty else {
            return
        }
        var targetFileName: String?
        if fileName != nil {
            targetFileName = fileName
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if fileNamePrefix != nil {
                targetFileName = "\(fileNamePrefix!)-\(dateString)"
            } else {
                targetFileName = dateString
            }
        }

        guard let fileURL = directoryURL()?.appendingPathComponent("\(targetFileName!).txt") else {
            return
        }

        let path = fileURL.absoluteString
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            do {
                try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            } catch _ {}
        }

        if let fileHandle = FileHandle(forWritingAtPath: path) {
            fileHandle.seekToEndOfFile()
            for info in infos {
                fileHandle.write(info.data(using: String.Encoding.utf8)!)
            }
            fileHandle.closeFile()
        }
    }

    static func directoryURL() -> URL? {
        return nil
    }

    static func allFiles() -> [SanboxModel] {
        guard let targetDirectory = directoryURL() else {
            return [SanboxModel]()
        }

        let fileManager = FileManager.default
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: targetDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            return [SanboxModel]()
        }

        let sortedFileURLs = fileURLs.sorted { first, second -> Bool in
            let firstAttributes = try? fileManager.attributesOfItem(atPath: first.path)
            let secondAttributes = try? fileManager.attributesOfItem(atPath: second.path)
            let firstDate = firstAttributes?[FileAttributeKey.creationDate] as? Date
            let secondDate = secondAttributes?[FileAttributeKey.creationDate] as? Date
            if firstDate != nil, secondDate != nil {
                return firstDate! > secondDate!
            }
            return false
        }

        var sanboxInfos = [SanboxModel]()
        for fileURL in sortedFileURLs {
            let model = SanboxModel(fileURL: fileURL, name: fileURL.lastPathComponent)
            sanboxInfos.append(model)
        }
        return sanboxInfos
    }

    static func deleteAllFiles() {
        guard let targetDirectory = directoryURL() else {
            return
        }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: targetDirectory)
        } catch {
            print("deleteAllFiles error:\(error.localizedDescription)")
        }
    }
}
