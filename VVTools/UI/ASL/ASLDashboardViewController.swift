//
//  ASLDashboardViewController.swift
//  VVTools
//
//  Created by jiaxin on 2019/8/28.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

class ASLDashboardViewController: UITableViewController {
    let soldier: ASLSoldier

    init(soldier: ASLSoldier) {
        self.soldier = soldier
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "日志记录"
        tableView.register(DashboardCell.self, forCellReuseIdentifier: "swithCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        print(title)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "swithCell", for: indexPath) as! DashboardCell
            cell.textLabel?.text = "打印日志开关"
            cell.toggle.isOn = soldier.isActive
            cell.toggleValueDidChange = { [weak self] isOn in
                if isOn {
                    self?.soldier.start()
                    print("打开日志")
                } else {
                    self?.soldier.end()
                    print("关闭日志")
                }
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "查看日志"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "清理日志"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let vc = ASLListViewController(dataSource: ASLFileManager.allFiles())
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            let alert = UIAlertController(title: "提示", message: "确认删除所有日志吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
                ASLFileManager.deleteAllFiles()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
