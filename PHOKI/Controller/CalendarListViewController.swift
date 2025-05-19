//
//  CalendarListViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/13.
//

import UIKit
import CoreData

class CalendarListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    let calendarInfoHelper = CalendarInfoHelper()
    var calendarInfoList = [CalendarInfoInstance]()
    let picker = UIImagePickerController()
    var editIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        btnUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendarInfoList = self.calendarInfoHelper.fetchCalendarInfoList()
        self.collectionView.reloadData()

//        DispatchQueue.global().async {
//            self.calendarInfoList = self.calendarInfoHelper.fetchCalendarInfoList()
//            DispatchQueue.main.sync {
//                self.collectionView.reloadData()
//            }
//        }
    }
    
    func btnUI(){
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowRadius = 3
        addButton.layer.shadowOpacity = 0.3
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "캘린더 추가".localized, message: "캘린더 이름을 입력해주세요".localized, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소".localized, style: .cancel, handler: nil)
        let save = UIAlertAction(title: "완료".localized, style: .default){ (save) in
            let title = alert.textFields?[0].text
            let uid:String = self.calendarInfoHelper.getUniqueIdOfCalendar()
            let timestamp:Int = Int(Date().timeIntervalSince1970)
            let calendarInfo = CalendarInfoInstance(title: title!, image: (UIImage(named: "bluecloud")?.jpegData(compressionQuality: 0.5))!, id: "\(uid)", index: timestamp)
            self.calendarInfoHelper.insertCalender(calInst: calendarInfo)
            self.calendarInfoList = self.calendarInfoHelper.fetchCalendarInfoList()
            self.collectionView.reloadData()
        }
        alert.addTextField{ (textField) in
            textField.placeholder = "캘린더 이름".localized
        }
        alert.addAction(cancel)
        alert.addAction(save)
        present(alert, animated: true, completion: nil)
    }
}

extension CalendarListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calcell", for: indexPath) as? CalendarInfoCell else {
            return UICollectionViewCell()
        }
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView?.backgroundColor = .lightGray
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.white
        cell.titleLabel.text = calendarInfoList[indexPath.item].title
        cell.imgView.image = UIImage(data: calendarInfoList[indexPath.item].image!)
        cell.imgView.layer.cornerRadius = 10
        
        cell.menuButton.showsMenuAsPrimaryAction = true
        //캘린더 이름 변경
        let editTitle = UIAction(title: "캘린더 이름 변경".localized, image: UIImage(systemName: "pencil"), handler: {(editTitle) in
            let alert = UIAlertController(title: "캘린더 이름 변경".localized, message: "변경할 캘린더 이름을 입력하세요".localized, preferredStyle: .alert)
            let save = UIAlertAction(title: "완료".localized, style: .default, handler: { _ in
                self.calendarInfoList[indexPath.item].title = (alert.textFields?[0].text)!
                self.calendarInfoHelper.updateCalendarInfo(calInst: self.calendarInfoList[indexPath.item])
                self.collectionView.reloadData()
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.calendarInfoList[indexPath.item].title
            })
            alert.addAction(save)
            self.present(alert, animated: true, completion: nil)
        })
        //캘린더 대표 사진 변경
        let editImage = UIAction(title: "대표 사진 변경".localized, image: UIImage(systemName: "photo"), handler: {_ in
            self.editIndex = indexPath.item
            self.present(self.picker, animated: true, completion: nil)
        })
        //캘린더 삭제
        let delete = UIAction(title: "캘린더 삭제".localized, image: UIImage(systemName: "trash"), handler: {_ in
            if self.calendarInfoList.count == 1 {
                let alertToOnlyOne = UIAlertController(title: "캘린더가 1개일 땐\n삭제할 수 없습니다.".localized, message: "새로운 캘린더를 추가한 후에 삭제해주세요.".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인".localized, style: .default, handler: nil)
                alertToOnlyOne.addAction(ok)
                self.present(alertToOnlyOne, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "캘린더 삭제".localized, message: "'\(self.calendarInfoList[indexPath.item].title)' " + "캘린더를 삭제하시겠습니까?".localized, preferredStyle: .alert)
                let delete = UIAlertAction(title: "삭제".localized, style: .destructive, handler: {_ in
                    self.calendarInfoHelper.deleteCalendar(calInst: self.calendarInfoList.remove(at: indexPath.item))
                    currentCalendarIndex = 0 // 캘린더 삭제시 홈탭 캘린더 1번째 캘린더로 지정
                    self.collectionView.reloadData()
                })
                let cancel = UIAlertAction(title: "취소".localized, style: .cancel, handler: nil)
                alert.addAction(delete)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
        let cancel = UIAction(title: "취소".localized, attributes: .destructive, handler: { _ in } )
        cell.menuButton.menu = UIMenu(title: "", image: UIImage(systemName: "heart.fill"), identifier: nil, options: .displayInline, children: [editTitle, editImage, delete, cancel])

        return cell
    }
}

extension CalendarListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.calendarInfoList[editIndex].image = image.jpegData(compressionQuality: 0.5)
        }
        dismiss(animated: true, completion: nil)
        self.collectionView.reloadData()
        self.calendarInfoHelper.updateCalendarInfo(calInst: self.calendarInfoList[editIndex])
    }
}

extension CalendarListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        currentCalendarIndex = indexPath.item
        
        //캘린더 선택시 현재 날짜의 캘린더 표시
        let vc = tabBarController?.children[0] as? ViewController
        vc?.selectedDate = Date()
        vc?.setMonthView()
        
        //사진 배열 초기화 - 캘린더 변경
        thumnails.removeAll()
        
        tabBarController?.selectedIndex = 0
    }
}

extension CalendarListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-30)/2
        let height = width + 70
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        return inset
    }
}

