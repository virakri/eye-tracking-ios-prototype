//
//  ViewController.swift
//  Eyes Tracking
//
//  Created by Virakri Jinangkul on 6/9/18.
//  Copyright © 2018 virakri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var mainTableView: UITableView!
    
    struct TableRow {
        var name: String
        var identifier: String
    }
    
    struct TableSection {
        var sectionName: String
        var sectionDescription: String?
        var rows: [TableRow]
    }
    
    let tableSections: [TableSection] = [TableSection(sectionName: "Initial Concept",
                                                     sectionDescription: nil,
                                                     rows: [TableRow(name: "Basic Eyes Tracking",
                                                                     identifier: "segueToEyesTracking")]),
                                         TableSection(sectionName: "Machine Learning Data Input",
                                                      sectionDescription: nil,
                                                      rows: [TableRow(name: "Data Input Visualization",
                                                                      identifier: "segueToMLDataDisplay"),
                                                             TableRow(name: "Data Input Capturing",
                                                                      identifier: "segueToMLCapturing")]),
                                         TableSection(sectionName: "Machine Learning Result",
                                                      sectionDescription: nil,
                                                      rows: [TableRow(name: "Eyes Tracking Using ML",
                                                                      identifier: "segueToMLEyesTracking")])]
    //segueToMLEyesTracking
    
    override func viewDidLoad() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        title = "Eyes Tracking"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Navigation Bar Setup
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.barStyle = .blackTranslucent
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Store isIdleTimerDisabled Value
        UIApplication.shared.isIdleTimerDisabled = false
        
        // Unselect tableview rows
        if let selectedRow = mainTableView.indexPathForSelectedRow {
            mainTableView.deselectRow(at: selectedRow, animated: animated)
        }
        
        // Navigation Bar Setup
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.barStyle = .blackTranslucent
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableSections[section].sectionDescription
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = tableSections[indexPath.section].rows[indexPath.row]
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = rowData.name
        cell.textLabel?.textColor = UIColor(red: 142/255, green: 146/255, blue: 141/255, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = tableSections[indexPath.section].rows[indexPath.row].identifier
        performSegue(withIdentifier: identifier, sender: self)
    }
    
}
