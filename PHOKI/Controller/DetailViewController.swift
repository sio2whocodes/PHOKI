//
//  DetailViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/11.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class DetailViewController: UIViewController {
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pager: UIPageControl!
    
    let picker = UIImagePickerController()
    let contentHelper = ContentHelper()
    let calendarHelper = CalendarHelper()
    let dateFormmater = DateFormatter()
    var myContent = MyContent(date: "",
                              images: [UIImage(named: "bluecloud")?.jpegData(compressionQuality: 0.5)],
                              memos: [""],
                              thumnail: UIImage(),
                              calId: calendarInfoList[currentCalendarIndex].id)
    let indicator = NVActivityIndicatorView(frame: CGRect(x:162, y: 100, width: 50, height: 50),
                                            type: .ballSpinFadeLoader,
                                            color: .gray,
                                            padding: 0)
    
    var now = ""
    var yearMonth = ""
    var date = ""
    var day = ""
    var idx = 0
    var isAdd = false
    let dayList = ["일요일","월요일","화요일","수요일","목요일","금요일","토요일"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myContent = (contentHelper.fetchContent(date: now, calId: calendarInfoList[currentCalendarIndex].id) as? MyContent)!
        picker.sourceType = .photoLibrary
        picker.delegate = self
        makeDateLabel()
        setIndicator()
        addButtonShadow()
        longPressGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !myContent.images.isEmpty {
            myContent.thumnail = UIImage(data: myContent.images[0]!)!.getThumbnail()!
            contentHelper.updateContent(mycontent: myContent)
        }
        let vc = presentingViewController?.children[0] as? ViewController
        vc?.viewWillAppear(true)
        vc?.collectionViewReload()
    }
    
    func makeDateLabel(){
        dateFormmater.dateFormat = "yyyy-MM-dd"
        dateFormmater.timeZone = TimeZone(identifier: "UTC")
        let yearIdx = yearMonth.index(yearMonth.startIndex, offsetBy: 4)
        let dayInt = calendarHelper.weekDay(date: dateFormmater.date(from: yearMonth[yearMonth.startIndex..<yearIdx]+"-"+yearMonth[yearIdx..<yearMonth.endIndex]+"-"+self.date)!)
        day = dayList[dayInt]
        yearLabel.text = String(yearMonth[yearMonth.startIndex..<yearIdx])
        
        //localization
        let month = calendarHelper.monthStringSingle(date: dateFormmater.date(from: yearMonth[yearMonth.startIndex..<yearIdx]+"-"+yearMonth[yearIdx..<yearMonth.endIndex]+"-"+self.date)!) + "월"
        dateLabel.text = month.localized + " " + self.date + "일".localized + ", " + self.day.localized
    }
    
    func setIndicator(){
        let centerX = self.view.bounds.width/2
        let centerY = self.view.bounds.height/2
        indicator.frame = CGRect(x: centerX-25, y: centerY-25, width: 50, height: 50)
        self.view.addSubview(indicator)
    }
    
    func longPressGesture(){
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(gesture)
        
        //TO DO : 위치 이동
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        indicator.startAnimating()
        isAdd = true
        present(picker, animated: true, completion: nil)
        indicator.stopAnimating()
    }
    
    func addButtonShadow(){
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addButton.layer.shadowRadius = 3
        addButton.layer.shadowOpacity = 0.3
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myContent.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailcell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        cell.memolabel.clipsToBounds = true
        cell.memolabel.layer.cornerRadius = 8
        
        cell.imgView.image = UIImage(data: myContent.images[indexPath.item]!)
        cell.imgView.layer.cornerRadius = 10
        
        cell.memoTextView.text = myContent.memos[indexPath.item]
        cell.memoTextView.tag = indexPath.item
        cell.memoTextView.addDoneButtonOnKeyBoard()
        
        cell.button.tag = indexPath.item
        cell.button.addTarget(self, action: #selector(imgbtnClick(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func imgbtnClick(sender: UIButton){
        idx = sender.tag
        var alert: UIAlertController
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "사진 수정".localized, message: "", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "사진 수정".localized, message: "", preferredStyle: .actionSheet)
        }
        let editAction = UIAlertAction(title: "사진 변경".localized,
                                       style: .default,
                                       handler: updateImg(_:))
        let deleteAction = UIAlertAction(title: "사진 삭제".localized,
                                         style: .destructive,
                                         handler: deleteImg(_:))
        let cancel = UIAlertAction(title: "취소".localized, style: .cancel, handler: nil)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func updateImg(_: UIAlertAction){
        isAdd = false
        present(picker, animated: true, completion: nil)
    }
    
    func deleteImg(_: UIAlertAction){
        if myContent.images.count == 1 {
            myContent.images.remove(at: idx)
            myContent.memos.remove(at: idx)
            contentHelper.deleteContent(mycontent: myContent)
            dismiss(animated: true, completion: nil)
        } else {
            myContent.images.remove(at: idx)
            myContent.memos.remove(at: idx)
            if idx == 0 {
                myContent.thumnail = UIImage(data:myContent.images[0]!)!.getThumbnail()!
            }
            collectionView.reloadData()
            contentHelper.updateContent(mycontent: myContent)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let targetImage = myContent.images.remove(at: sourceIndexPath.item)
        let targetMemo = myContent.memos.remove(at: sourceIndexPath.item)
        myContent.images.insert(targetImage, at: destinationIndexPath.item)
        myContent.memos.insert(targetMemo, at: destinationIndexPath.item)
    }
    
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 30
        let height = collectionView.frame.height - 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //사진 추가
            if isAdd {
                self.myContent.images.append(image.jpegData(compressionQuality: 0.5))
                self.myContent.memos.append("")
            }
            //사진 변경
            else {
                self.myContent.images[idx] = image.jpegData(compressionQuality: 0.5)
                self.myContent.thumnail = UIImage(data: self.myContent.images[0]!)!.getThumbnail()!
            }
            contentHelper.updateContent(mycontent: myContent)
            contentHelper.fetchContentThumnail(date: now,
                                               calId: calendarInfoList[currentCalendarIndex].id)
        }
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("end")
        view.endEditing(true)
    }
}

extension DetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textView.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 1000
    }
    
    
    @objc func keyBoardWillShow(_ sender: Notification){
        self.view.frame.origin.y = -280
    }
    
    @objc func keyBoardWillHide(_ sender: Notification){
        self.view.frame.origin.y = 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let curruntCell = collectionView.visibleCells[0] as! ImageCell
        curruntCell.button.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        myContent.memos[textView.tag] = textView.text
        contentHelper.updateContent(mycontent: myContent)
        let curruntCell = collectionView.visibleCells[0] as! ImageCell
        curruntCell.button.isHidden = false
    }
}

extension UITextView {
    func addDoneButtonOnKeyBoard(){
        let doneToolBar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        doneToolBar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "완료".localized, style: .done, target: nil, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        
        self.inputAccessoryView = doneToolBar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var memolabel: UILabel!
}

