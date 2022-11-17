//
//  SettingViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/13.
//

import Foundation
import UIKit
import CoreData
import NVActivityIndicatorView
import MessageUI

class SettingViewController: UIViewController,
                             MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copyrightLabel: UILabel!
    let menuList = ["앱 리뷰하기","앱 피드백 보내기","배너 광고 제거","라이선스","버전 정보"]
    let sec2 = ["라이선스","버전 정보"]
    let sec3 = ["광고"]
    let sections = ["PHOKI","about app", "광고"]
    let indicator = NVActivityIndicatorView(frame: CGRect(x:162, y: 100, width: 50, height: 50),
                                            type: .ballSpinFadeLoader,
                                            color: .gray,
                                            padding: 0)
    
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copyrightLabel.text = " ⓒ 2021 S.J LIM"
        let centerX = self.view.bounds.width/2
        let centerY = self.view.bounds.height/2
        indicator.frame = CGRect(x: centerX-25, y: centerY-25, width: 50, height: 50)
        self.view.addSubview(indicator)
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "adCell", for: indexPath) as? AdCell
            else { return UITableViewCell() }
            cell.label.text = menuList[indexPath.row]
            if let adFreeDay = UserDefaults.standard.object(forKey: "adFreeDay") as? Date {
                if adFreeDay < Date() {
                    cell.dayLabel.text = "광고 보기"
                } else {
                    let ti = Int((adFreeDay.timeIntervalSince(Date()))/86400+1)
                    cell.dayLabel.text = "\(ti)일 남음"
                }
            } else {
                cell.dayLabel.text = "광고 보기"
            }
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "licenseCell", for: indexPath) as? EtcCell
            else { return UITableViewCell() }
            cell.label.text = menuList[indexPath.row]
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 4 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath) as? VerCell
            else { return UITableViewCell() }
            cell.label.text = menuList[indexPath.row]
            cell.verNum.text = version
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "etcCell", for: indexPath) as? EtcCell
            else { return UITableViewCell() }
            cell.label.text = menuList[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1562617132?action=write-review"),
                    UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let compseVC = MFMailComposeViewController()
                    compseVC.mailComposeDelegate = self
                    compseVC.setToRecipients(["sio2whocodes.apps.feedback@gmail.com"])
                    compseVC.setSubject("[PHOKI] feedback")
                    compseVC.setMessageBody("\n\n---------\nmy app version : \(String(version!))", isHTML: false)
                    self.present(compseVC, animated: true, completion: nil)
                }
//            //백업
//            case 2:
//                let alert = UIAlertController(title: "데이터를 백업하시겠습니까?", message: "백업된 데이터는 아이클라우드에 저장됩니다", preferredStyle: .alert)
//                let copyAction = UIAlertAction(title: "예", style: .default, handler: copyData(_:))
//                let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
//                alert.addAction(copyAction)
//                alert.addAction(cancelAction)
//                present(alert, animated: true, completion: nil)
//            //복원
//            case 3:
//                let alert = UIAlertController(title: "데이터를 복원하시겠습니까?", message: "아이클라우드에 저장된 데이터로 복원됩니다", preferredStyle: .alert)
//                let restoreAction = UIAlertAction(title: "예", style: .default, handler: restoreData(_:))
//                let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
//                alert.addAction(restoreAction)
//                alert.addAction(cancelAction)
//                present(alert, animated: true, completion: nil)
            default:
                print()
        }
    }
    
    func copyData(_: UIAlertAction){
        indicator.startAnimating()
        var loadingSec = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            loadingSec += 1
            if loadingSec > 30 {
                self.timer?.invalidate()
                self.timer = nil
                self.indicator.stopAnimating()
            }
        }
        DispatchQueue.main.async {
            let fileManager = FileManager.default
            let icloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("Data")
            do {
               try appDelegate.persistentContainer.copyPersistentStores(to: icloudURL!, overwriting: true)
               self.indicator.stopAnimating()
               let alert = UIAlertController(title: "백업 완료", message: "PHOKI 데이터 백업이 완료되었습니다🎉", preferredStyle: .alert)
               let action = UIAlertAction(title: "확인", style: .default, handler: nil)
               alert.addAction(action)
               self.present(alert, animated: true, completion: nil)
            } catch {
               print(error)
               self.indicator.stopAnimating()
               let alert = UIAlertController(title: "백업 실패", message: "PHOKI 데이터 백업이 진행되지 않았습니다. 다시 시도해주세요😥", preferredStyle: .alert)
               let action = UIAlertAction(title: "확인", style: .default, handler: nil)
               alert.addAction(action)
               self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func restoreData(_: UIAlertAction){
        indicator.startAnimating()
        var loadingSec = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            loadingSec += 1
            if loadingSec > 30 {
                self.timer?.invalidate()
                self.timer = nil
                self.indicator.stopAnimating()
            }
        }
        DispatchQueue.main.async {
            let fileManager = FileManager.default
            let icloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("Data")
            do {
                try appDelegate.persistentContainer.restorePersistentStore(from: icloudURL!)
                self.indicator.stopAnimating()
                let alert = UIAlertController(title: "복원 완료", message: "PHOKI 데이터 복원이 완료되었습니다🎉", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                thumnails.removeAll()
            } catch {
                print(error)
                self.indicator.stopAnimating()
                let alert = UIAlertController(title: "복원 실패", message: "PHOKI 데이터 복원이 진행되지 않았습니다. 다시 시도해주세요😥 \n 파일 앱 > iCloud Drive > PHOKI > Data 안의 파일들이 다운받아져 있는지 확인해주세요.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}




class EtcCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class VerCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var verNum: UILabel!
}

class AdCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
}
