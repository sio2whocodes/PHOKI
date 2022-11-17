//
//  ViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/08.
//

import UIKit
import CoreData
import GoogleMobileAds
import NVActivityIndicatorView

var thumnails = [String:UIImage]()
var calendarInfoList = [CalendarInfoInstance]()
var currentCalendarIndex: Int = 0

class ViewController: UIViewController, GADBannerViewDelegate, GADFullScreenContentDelegate {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var CalendarLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var adBannerView: UIView!
    @IBOutlet weak var addButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var adcloseTrailingCst: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    private var rewardedAd: GADRewardedAd?
    let indicator = NVActivityIndicatorView(frame: CGRect(x:162, y: 100, width: 50, height: 50),
                                            type: .ballSpinFadeLoader,
                                            color: .gray,
                                            padding: 0)

    var selectedDate = Date()
    var totalDates = [String]()
    let calendarHelper = CalendarHelper()
    let picker = UIImagePickerController()
    let contentHelper = ContentHelper()
    let calendarInfoHelper = CalendarInfoHelper()
    var now = ""
    var yymm = ""
    var adPresent = false
    var timer: Timer?
    var calendarIndex = currentCalendarIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        swipeSetting()
        uisetting()
        addButtonShadow()
        setIndicator()
        selectedDate = Date()
        setMonthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let adFreeDay = UserDefaults.standard.object(forKey: "adFreeDay") as? Date {
            adPresent = adFreeDay < Date()
        } else {
            adPresent = true
        }
        if adPresent {
            AdBannerSetting()
        } else {
            removeBanner()
        }
        calendarInfoList = calendarInfoHelper.fetchCalendarInfoList()
        if calendarInfoList.count == 0 {
            let cii = CalendarInfoInstance(title: "MY CALENDAR", image: (UIImage(named: "bluecloud")?.jpegData(compressionQuality: 1))!, id: "0", index: 0)
            calendarInfoHelper.insertCalender(calInst: cii)
            calendarInfoList = calendarInfoHelper.fetchCalendarInfoList()
        }
        CalendarLabel.text = calendarInfoList[currentCalendarIndex].title
        titleImageView.image = UIImage(data: calendarInfoList[currentCalendarIndex].image!)
        contentHelper.fetchContents(calId: calendarInfoList[currentCalendarIndex].id)
    }

    func collectionViewReload(){
        self.collectionView.reloadData()
    }
    
    func swipeSetting(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer){
        if sender.direction == .left {
            var frame = collectionView.frame
            frame.origin.x -= collectionView.frame.width
            UIView.animate(withDuration: 0.4){
                self.collectionView.frame = frame
            }
            selectedDate = calendarHelper.nextMonth(date: selectedDate)
        } else if sender.direction == .right {
            var frame = collectionView.frame
            frame.origin.x += collectionView.frame.width
            UIView.animate(withDuration: 0.4){
                self.collectionView.frame = frame
            }
            selectedDate = calendarHelper.previousMonth(date: selectedDate)
        }
        setMonthView()
    }
    
    func uisetting(){
        collectionView.layer.cornerRadius = 5
        collectionView.layer.shadowColor = UIColor.darkGray.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
        collectionView.layer.shadowRadius = 5
        collectionView.layer.shadowOpacity = 0.2
        
        titleImageView.layer.cornerRadius = 10
        titleImageView.layer.shadowColor = UIColor.darkGray.cgColor
        titleImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        titleImageView.layer.shadowRadius = 3
        titleImageView.layer.shadowOpacity = 0.2
        
        backgroundView.layer.cornerRadius = 10
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.shadowColor = UIColor.darkGray.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundView.layer.shadowRadius = 3.0
        backgroundView.layer.shadowOpacity = 0.2
    }
    
    func addButtonShadow(){
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowRadius = 3
        addButton.layer.shadowOpacity = 0.3
    }
    
    func AdBannerSetting(){
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.delegate = self
        bannerView.adUnitID = bannerAdId
        bannerView.rootViewController = self
        bannerView.isAutoloadEnabled = true
        
        addBannerViewToView(bannerView)
        
        bannerView.isHidden = false
        addButtonBottomConstraint.constant = 65
        addButton.updateConstraints()
        adBannerView.isHidden = false
        collectionViewBottomConstraint.constant = 50
        adcloseTrailingCst.constant = (view.bounds.width-345)/2
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adBannerView.addSubview(bannerView)
        adBannerView.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: adBannerView,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .leading,
                              relatedBy: .equal,
                              toItem: adBannerView,
                              attribute: .leading,
                              multiplier: 1,
                              constant: 0)
        ])
    }
    
    func removeBanner(){
        adBannerView.isHidden = true
        addButtonBottomConstraint.constant = 15
        addButton.updateConstraints()
        collectionViewBottomConstraint.constant = 7
        if (bannerView != nil) {
            bannerView.isAutoloadEnabled = false
            bannerView.isHidden = true
            bannerView.removeFromSuperview()
            bannerView.delegate = nil
        }
    }
    
    @IBAction func adCloseBtn(_ sender: Any) {
        let alert = UIAlertController(title: "배너 광고 제거", message: "동영상 광고를 시청하면 10일 동안 배너광고가 나타나지 않습니다.", preferredStyle: .alert)
        let palyAction = UIAlertAction(title: "광고 시청", style: .default, handler: startRewardAd(_:))
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(palyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func startRewardAd(_: UIAlertAction){
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
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: rewardAdId,
                           request: request) { (ad, error) in
                    if let error = error {
                        print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "광고 로딩 실패", message: "광고를 불러오지 못했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                        let act = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                        alert.addAction(act)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.rewardedAd = ad
                    self.rewardedAd?.fullScreenContentDelegate = self
                    self.indicator.stopAnimating()
                    self.rewardedAd?.present(fromRootViewController: self, userDidEarnRewardHandler: self.getReward)
                }
    }
    
    func getReward(){
        let reward = self.rewardedAd?.adReward
        print("Reward received with currency \(String(describing: reward?.amount))")
        if reward?.amount as! Int >= 1 {
            let adFreeDay = Date(timeIntervalSinceNow: 86400*10)
            UserDefaults.standard.set(adFreeDay, forKey: "adFreeDay")
            self.viewWillAppear(true)
        }
    }
    
    
    func setIndicator(){
        let centerX = self.view.bounds.width/2
        let centerY = self.view.bounds.height/2
        indicator.frame = CGRect(x: centerX-25, y: centerY-25, width: 50, height: 50)
        self.view.addSubview(indicator)
    }
    
    func setMonthView() {
        totalDates.removeAll()
        let datesInMonth = calendarHelper.numOfDatesInMonth(date: selectedDate)
        let firstDayOfMonth = calendarHelper.firstDayOfMonth(date: selectedDate)
        let startingSpaces = calendarHelper.weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42){
            if count <= startingSpaces || count - startingSpaces > datesInMonth {
                totalDates.append("")
            }else{
                totalDates.append("\(count-startingSpaces)")
            }
            count += 1
        }
 
        monthLabel.text = calendarHelper.monthString(date: selectedDate) + "월 " + calendarHelper.yearString(date: selectedDate)
        yymm = calendarHelper.yearString(date: selectedDate) + calendarHelper.monthString(date: selectedDate)
        self.collectionView.reloadData()
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = calendarHelper.previousMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = calendarHelper.nextMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func addBtn(_ sender: Any) {
        indicator.startAnimating()
        present(picker, animated: true, completion: nil)
        indicator.stopAnimating()
        now = String(calendarHelper.yearString(date: Date())) + String(calendarHelper.monthString(date: Date())) + String(calendarHelper.dayOfMonth(date: Date()))
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return totalDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        now = yymm + totalDates[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        cell.dayOfMonth.text = totalDates[indexPath.item]

        DispatchQueue.main.async {
            self.now = self.yymm + self.totalDates[indexPath.item]
            if cell.dayOfMonth.text != "" {
                cell.imgView.image = thumnails[self.yymm + self.totalDates[indexPath.item]]
                cell.imgView.layer.cornerRadius = 2
                cell.contentView.bringSubviewToFront(cell.imgView)
            }else{
                cell.imgView.image = nil
            }
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width)/8 + 5
        let height = (collectionView.frame.size.height)/6
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        return inset
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        now = yymm + totalDates[indexPath.item]
        if totalDates[indexPath.item] != "" {
            if thumnails[now] == nil {
                indicator.startAnimating()
                present(picker, animated: true, completion: nil)
                indicator.stopAnimating()
            } else {
                performSegue(withIdentifier: "showdetail", sender: now)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showdetail" {
            if let cell = sender as? CalendarCell {
                if cell.imgView.image == nil {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdetail" {
            if let vc = segue.destination as? DetailViewController {
                if let cell = sender as? CalendarCell {
                    vc.now = yymm + cell.dayOfMonth.text!
                    vc.yearMonth = yymm
                    vc.date = cell.dayOfMonth.text!
                }
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            if thumnails[now] != nil {
                var nowContent = contentHelper.fetchContent(date: now, calId: calendarInfoList[currentCalendarIndex].id) as! MyContent
                nowContent.images.append(image.jpegData(compressionQuality: 0.5))
                nowContent.memos.append("")
                contentHelper.updateContent(mycontent: nowContent)
            } else {
                let mycontent = MyContent(date: now, images: [image.jpegData(compressionQuality: 0.5)], memos: [""], thumnail: image.getThumbnail()!, calId: calendarInfoList[currentCalendarIndex].id)
                contentHelper.insertContent(mycontent: mycontent)
            }
            dismiss(animated: true, completion: nil)
            contentHelper.fetchContentThumnail(date: now, calId: calendarInfoList[currentCalendarIndex].id)
            collectionView.reloadData()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
