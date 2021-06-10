//
//  AdViewController.swift
//  PHOKI
//
//  Created by 임수정 on 2021/04/04.
//

import UIKit
import GoogleMobileAds
import NVActivityIndicatorView

class AdViewController: UIViewController, GADFullScreenContentDelegate {

    @IBOutlet weak var adButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    private var rewardedAd: GADRewardedAd?
    var timer: Timer?
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x:162, y: 100, width: 50, height: 50),
                                            type: .ballSpinFadeLoader,
                                            color: .gray,
                                            padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        label.text = "동영상 광고를 시청하면\n10일 동안 배너광고가 나타나지 않습니다.\n광고 시청은 앱을 무료로 운영하는 데에\n도움이 됩니다."
        adButton.isHidden = true
        subLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let adFreeDay = UserDefaults.standard.object(forKey: "adFreeDay") as? Date {
            if Date() <= adFreeDay {
                let ti = Int((adFreeDay.timeIntervalSince(Date()))/86400+1)
                subLabel.text = "\(ti)일 동안 배너 광고가 나타나지 않습니다."
                adButton.isHidden = true
            } else {
                subLabel.isHidden = true
                loadRewardedAd()
            }
        } else {
            subLabel.isHidden = true
            loadRewardedAd()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.children[2].viewWillAppear(true)
    }
    
    func setIndicator(){
        let centerX = self.view.bounds.width/2 - 25
        let centerY = self.view.bounds.height/2 + 77
        indicator.frame = CGRect(x: centerX, y: centerY, width: 50, height: 50)
        self.view.addSubview(indicator)
    }
    
    func loadRewardedAd() {
        indicator.startAnimating()
        let request = GADRequest()
        var loadingSec = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            loadingSec += 1
            if loadingSec > 30 {
                self.timer?.invalidate()
                self.timer = nil
                self.indicator.stopAnimating()
            }
        }
        GADRewardedAd.load(withAdUnitID: rewardAdId,
                           request: request) { (ad, error) in
                  if let error = error {
                      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "광고 로딩 실패", message: "광고를 불러오지 못했습니다\n다시 시도해 주세요", preferredStyle: .alert)
                    let act = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                    alert.addAction(act)
                    self.present(alert, animated: true, completion: nil)
                      return
                  }
                  self.rewardedAd = ad
                  self.rewardedAd?.fullScreenContentDelegate = self
                  self.indicator.stopAnimating()
                  self.adButton.isHidden = false
              }
    }
    
    @IBAction func adPlayButton(_ sender: Any) {
        if (self.rewardedAd != nil) {
            self.rewardedAd?.present(fromRootViewController: self) {
                let reward = self.rewardedAd?.adReward
                print("Reward received with currency \(String(describing: reward?.amount))")
                if reward?.amount as! Int >= 1 {
                    let adFreeDay = Date(timeIntervalSinceNow: 86400*10)
                    UserDefaults.standard.set(adFreeDay, forKey: "adFreeDay")
                    self.subLabel.isHidden = false
                }
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
}
