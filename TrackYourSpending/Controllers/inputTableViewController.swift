//
//  inputTableViewController.swift
//  TestSlideMenu
//
//  Created by 江宗翰 on 2018/1/4.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import UIKit
import CoreData
import SwiftMessages
class inputTableViewController: UITableViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var moodPickerView: UIPickerView!
    @IBOutlet weak var billingTypePickerView: UIPickerView!
    @IBOutlet weak var moneyTypeLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var billingType: UILabel!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    
    var keyHeight2 = 0
    let formatter = DateFormatter()
    var startDatePickerHidden = true
    var typePickerHidden = true
    var moodPickerHidden = true
    var billingPickerHidden = true
    var tableViewContentY:CGFloat = 0.0
    var inputDate = NSDate()
    
    var moneyTypes = [MoneyType]()
    var moods = [Mood]()
    var incomes = ["薪水","獎金","投資","其他"]
    var incomesEmo = ["💰","💵","📈","💎"]
    var moneyTypeRow = 0
    var moodRow = 0
    var billingTypeRow = 0
    var isEdit = false
    
    var billingTypeArr = ["支出","收入"]
    var billing:Billing = Billing()
    var calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //建立鍵盤彈出事件
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow2),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        getMoods()
        getMoneyTypes()
        formatter.dateFormat = "yyyy年MM月dd日"
        startDatePicker.date = inputDate as Date
        startTime.text = formatter.string(from: inputDate as Date)
        startDatePicker.setValue(UIColor.white, forKey: "textColor")
        moneyTypeLabel.text = "\(moneyTypes[0].emoji!)\(moneyTypes[0].text!)"
        moodLabel.text = "\(moods[0].emoji!)\(moods[0].text!)"
        remarkTextView.layer.cornerRadius = 20
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        if isEdit {
            sendBtn.title = "修改"
            billingTypePickerView.selectRow(Int(billing.billing_type), inComponent: 0, animated: true)
            moneyTextField.text = String(billing.money)
            startTime.text = formatter.string(from: billing.date! as Date)
            var moodFlag = 0
            for m in moods {
                if m.text == billing.mood{
                    moodPickerView.selectRow(moodFlag, inComponent: 0, animated: true)
                    moodLabel.text = "\(m.emoji!)\(m.text!)"
                    break
                }
                moodFlag += 1
            }
            
            var typeFlag = 0
            if billing.billing_type == 0{
                billingType.text = "支出"
                billingTypeRow = 0
                for b in moneyTypes{
                    if b.text == billing.money_type{
                        typePickerView.selectRow(typeFlag, inComponent: 0, animated: true)
                        moneyTypeLabel.text = "\(b.emoji!)\(b.text!)"
                        break
                    }
                    typeFlag += 1
                }
            }else{
                billingType.text = "收入"
                billingTypeRow = 1
                for i in incomes{
                    if i == billing.money_type{
                        typePickerView.selectRow(typeFlag, inComponent: 0, animated: true)
                        moneyTypeLabel.text = "\(incomes[typeFlag])\(incomesEmo[typeFlag])"
                        break
                    }
                    typeFlag += 1
                }
            }
            moneyTextField.text = String(billing.money)
            remarkTextView.text = billing.note
        }
    }
    
    func getMoods(){
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        let sort = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do{
            let mood = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            self.moods = mood
        }catch{
            
        }
    }
    
    func getMoneyTypes(){
        let fetchRequest: NSFetchRequest<MoneyType> = MoneyType.fetchRequest()
        let sort = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do{
            let moneyType = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            self.moneyTypes = moneyType
        }catch{
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @objc func keyboardWillShow2(notification: NSNotification) {
        if keyHeight2 == 0{
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyHeight2 = Int(keyboardHeight)
        }
    }
    
    //儲存
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        
        if moneyTextField.text == "" {
            let view = MessageView.viewFromNib(layout: .cardView)
            view.button?.isHidden = true
            view.configureTheme(.warning)
            view.configureContent(title: "錯誤", body: "請輸入金額")
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
            SwiftMessages.show(view: view)
        }else{
            if isEdit {
                billing.money = Int32(moneyTextField.text!)!
                billing.note = remarkTextView.text
                billing.billing_type = Int32(billingTypeRow)
                billing.mood = moods[moodRow].text
                billing.mood_emoji = moods[moodRow].emoji
                
                if billingTypeRow == 0{
                    billing.money_type = moneyTypes[moneyTypeRow].text
                    billing.money_type_emoji = moneyTypes[moneyTypeRow].emoji
                }else{
                    billing.money_type = incomes[moneyTypeRow]
                    billing.money_type_emoji = incomesEmo[moneyTypeRow]
                }
                
                billing.date = calendar.startOfDay(for: startDatePicker.date) as NSDate
                CoreDataService.coreDataService.saveContext()
            }else{
                billing = Billing(context: CoreDataService.coreDataService.context)
                billing.id = UUID()
                billing.create_date = NSDate()
                billing.money = Int32(moneyTextField.text!)!
                billing.note = remarkTextView.text
                billing.billing_type = Int32(billingTypeRow)
                billing.mood = moods[moodRow].text
                billing.mood_emoji = moods[moodRow].emoji
                
                if billingTypeRow == 0{
                    billing.money_type = moneyTypes[moneyTypeRow].text
                    billing.money_type_emoji = moneyTypes[moneyTypeRow].emoji
                }else{
                    billing.money_type = incomes[moneyTypeRow]
                    billing.money_type_emoji = incomesEmo[moneyTypeRow]
                }
                
                billing.date = calendar.startOfDay(for: startDatePicker.date) as NSDate
                CoreDataService.coreDataService.saveContext()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //回上頁
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //按任意處
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //收起鍵盤
        self.view.endEditing(true)
        SwiftMessages.hide()
        //tableView滑回原本位置
//        tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section:\(indexPath.section)  cell:\(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0 {
            billingPickerHidden = !billingPickerHidden
            startDatePickerHidden = true
            typePickerHidden = true
            moodPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }else if indexPath.section == 0 && indexPath.row == 2 {
            startDatePickerHidden = !startDatePickerHidden
            billingPickerHidden = true
            typePickerHidden = true
            moodPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }else if indexPath.section == 0 && indexPath.row == 5 {
            typePickerHidden = !typePickerHidden
            startDatePickerHidden = true
            billingPickerHidden = true
            moodPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }else if indexPath.section == 0 && indexPath.row == 7 {
            moodPickerHidden = !moodPickerHidden
            startDatePickerHidden = true
            typePickerHidden = true
            billingPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if billingPickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        }else if startDatePickerHidden && indexPath.section == 0 && indexPath.row == 3 {
            return 0
        }else if typePickerHidden && indexPath.section == 0 && indexPath.row == 6 {
            return 0
        }else if moodPickerHidden && indexPath.section == 0 && indexPath.row == 8 {
            return 0
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    //datePickerView的aciton
    @IBAction func datePickerValue(_ sender: UIDatePicker) {
        formatter.dateFormat = "yyyy 年 MM 月 dd 日"
        startTime.text = formatter.string(from: sender.date)
    }
    
    
    
}

extension inputTableViewController:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //pickerView數量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePickerView {
            if billingTypeRow == 0{
                return moneyTypes.count
            }else{
                return incomes.count
            }
        }else if pickerView == moodPickerView {
            return moods.count
        }else{
            return billingTypeArr.count
        }
    }

    
    //pickerView改變字的顏色
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString:NSAttributedString!
        if pickerView == typePickerView {
            if billingTypeRow == 0{
               attributedString = NSAttributedString(string: "\(moneyTypes[row].emoji!)\(moneyTypes[row].text!)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            }else{
                attributedString = NSAttributedString(string: "\(incomesEmo[row])\(incomes[row])", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            }
            
        }else if pickerView == moodPickerView {
            attributedString = NSAttributedString(string: "\(moods[row].emoji!)\(moods[row].text!)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        }else{
            attributedString = NSAttributedString(string: billingTypeArr[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        }
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePickerView {
            if billingTypeRow == 0{
                moneyTypeLabel.text = "\(moneyTypes[row].emoji!)\(moneyTypes[row].text!)"
            }else{
                moneyTypeLabel.text = "\(incomesEmo[row])\(incomes[row])"
            }
            moneyTypeRow = row
        }else if pickerView == moodPickerView {
            moodLabel.text = "\(moods[row].emoji!)\(moods[row].text!)"
            moodRow = row
        }else{
            billingType.text = billingTypeArr[row]
            billingTypeRow = row
            self.navigationItem.title = billingTypeArr[row]
            if row == 0{
                moneyTypeLabel.text = "\(moneyTypes[0].emoji!)\(moneyTypes[0].text!)"
            }else{
                moneyTypeLabel.text = "\(incomesEmo[0])\(incomes[0])"
            }
        }
        pickerView.reloadAllComponents()
    }
}

extension inputTableViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        typePickerHidden = true
        startDatePickerHidden = true
        billingPickerHidden = true
        moodPickerHidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.setContentOffset(CGPoint(x:0,y:keyHeight2-100), animated: true)
        tableViewContentY = tableView.contentOffset.y
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        typePickerHidden = true
        startDatePickerHidden = true
        billingPickerHidden = true
        moodPickerHidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.setContentOffset(CGPoint(x:0,y:tableViewContentY), animated: true)
        return true
    }
    
    
}

