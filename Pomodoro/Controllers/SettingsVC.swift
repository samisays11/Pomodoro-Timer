//
//  SettingsVC.swift
//  Pomodoro
//
//  Created by Osaretin Uyigue on 8/2/22.
//

import UIKit
fileprivate let cellReuseIdentifier = "SettingsVC-cellReuseIdentifier"
class SettingsVC: UITableViewController {
    
    //MARK: - View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    

    //MARK: - Properties
    fileprivate let settingsSection: [SettingsItem] = [
        .siriShortCuts,
        .timerSettings,
        .toggleSettings,
        .workSessions,
        .more ]
    
    
    //MARK: - Methods
    fileprivate func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
    }
    
    
   
    
}



//MARK: - TableView DataSource & Delegates
extension SettingsVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.backgroundColor = .white
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSection.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel()
        let sectionTitle = settingsSection[section]
        
        titleLabel.text = "   \(sectionTitle.description)"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .appMainColor
        titleLabel.backgroundColor = .white
        return titleLabel
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

let deviceNames: [String] = [
    "iPhone SE (2nd generation)"
]

@available(iOS 13.0, *)
struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        ForEach(deviceNames, id: \.self) { deviceName in
            UIViewControllerPreview {
                SettingsVC()
            }.previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
#endif