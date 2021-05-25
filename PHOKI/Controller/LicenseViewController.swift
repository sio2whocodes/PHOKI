//
//  LicenseViewController.swift
//  PHOKI
//
//  Created by 임수정 on 2021/04/07.
//

import UIKit
import Foundation

class LicenseViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    let licenseList = ["NVActivityIndicatorView"]
    let licenseLinks = ["https://github.com/ninjaprox/NVActivityIndicatorView#license"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "licCell", for: indexPath) as? LicenseCell
        else { return UITableViewCell() }
        cell.label.text = licenseList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        if let url = URL(string: licenseLinks[indexPath.row]),
           UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}

class LicenseCell : UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

