//
//  ASLSoldier.swift
//  VVTools
//
//  Created by 赵江明 on 2024/6/24.
//

import Foundation

public class ASLSoldier: Soldier {
    public var name: String
    public var team: String
    public var icon: UIImage?
    public let asl: ASL
    public var threshold: Double = 1
    var isActive: Bool {
        set { UserDefaults.standard.isASLSoldierActive = newValue }
        get { UserDefaults.standard.isASLSoldierActive }
    }
    public init() {
        name = "日志"
        team = "性能检测"
        icon = ImageManager.imageWithName("VVTools_icon_anr")
        
        asl = ASL()
    }

    public func prepare() {
        start()
    }

    public func action(naviController: UINavigationController) {
        naviController.pushViewController(ASLDashboardViewController(soldier: self), animated: true)
    }

    public func start() {
        asl.open(with: threshold)
        isActive = true
    }

    public func end() {
        asl.close()
        isActive = false
    }
}

