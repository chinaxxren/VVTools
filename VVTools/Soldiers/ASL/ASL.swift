//
//  ASLEye.swift
//  Pods
//
//  Created by zixun on 16/12/25.
//
//

import asl
import Foundation

open class ASL: NSObject {
    let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "UnknownApp"
    
    public var fileName: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }()
    
    open var isOpening: Bool {
        return self.timer?.isValid ?? false
    }
    
    open func open(with interval: TimeInterval) {
        self.timer = Timer.scheduledTimer(timeInterval: interval,
                                          target: self,
                                          selector: #selector(ASL.pollingLogs),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    open func close() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc fileprivate func pollingLogs() {
        self.queue.async {
            let logs = self.retrieveLogs()
            if logs.count > 0 {
                DispatchQueue.main.async {
                    ASLFileManager.saveInfos(logs, fileName: self.fileName)
                }
            }
        }
    }
    
    fileprivate func retrieveLogs() -> [String] {
        var logs = [String]()
                        
        // 执行搜索
        let client = asl_open(nil, bundleIdentifier, 0) // 使用默认标识和设备

        let query: aslmsg = self.initQuery()
        
        let response: aslresponse? = asl_search(client, query)
        guard response != nil else {
            return logs
        }
        
        var message = asl_next(response)
        while message != nil {
            let log = self.parserLog(from: message!)
            logs.append(log)
            
            message = asl_next(response)
        }
        asl_free(response)
        asl_free(query)
        
        return logs
    }
    
    fileprivate func parserLog(from message: aslmsg) -> String {
        let content = asl_get(message, ASL_KEY_MSG)!
        let msg_id = asl_get(message, ASL_KEY_MSG_ID)
        
        let m = atoi(msg_id)
        if m != 0 {
            self.lastMessageID = m
        }
        
        return String(cString: content, encoding: String.Encoding.utf8)!
    }
    
    fileprivate func initQuery() -> aslmsg {
        let query: aslmsg = asl_new(UInt32(ASL_TYPE_QUERY))
        // set BundleIdentifier to ASL_KEY_FACILITY
        let bundleIdentifier = (bundleIdentifier as NSString).utf8String
        asl_set_query(query, ASL_KEY_FACILITY, bundleIdentifier, UInt32(ASL_QUERY_OP_EQUAL))
        
        // set pid to ASL_KEY_PID
        let pid = NSString(format: "%d", getpid()).cString(using: String.Encoding.utf8.rawValue)
        asl_set_query(query, ASL_KEY_PID, pid, UInt32(ASL_QUERY_OP_NUMERIC))
        
        if self.lastMessageID != 0 {
            let m = NSString(format: "%d", self.lastMessageID).utf8String
            asl_set_query(query, ASL_KEY_MSG_ID, m, UInt32(ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC))
        }
        
        return query
    }
    
    fileprivate var timer: Timer?
    
    fileprivate var lastMessageID: Int32 = 0
    
    fileprivate var queue = DispatchQueue(label: "ASLQueue")
}
