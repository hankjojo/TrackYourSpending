//
//  ViewController.swift
//  TestSlideMenu
//
//  Created by 江宗翰 on 2018/1/2.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
class ViewController: UIViewController{
    let formetter = DateFormatter()
    @IBOutlet weak var calenderView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var myScroll: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var billings = [Billing]()
    var incomes = [Billing]()
    var editBilling:Billing?
    var billngMoney = 0
    var incomeMoney = 0
    var isEdit = false
    var billingDate = [Date]()
    
    var selectDate:Date?
    var section = ["支出"]
    let selectedMonthColor = UIColor(colorWithHexValue: 0xFFFFF3)
    
    //螢幕轉向事件
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //calender的layout受到改變日期會跑到最前面,加上這行讓他維持在當下日期
        calenderView.viewWillTransition(to: size, with: coordinator, anchorDate: selectDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
        setCalenderView()
        calenderView.selectDates([Date()])
        calenderView.visibleDates{ (visibleDates) in
            self.setupViewOfCalender(from: visibleDates)
        }
        selectDate = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBillings(date: selectDate!)
        calenderView.reloadData()
        calenderView.selectDates([selectDate!])
        
        getAllbillingDate()
    }
    
    override func viewDidLayoutSubviews() {
        //calender的layout受到改變日期會跑到最前面,加上這行讓他維持在當下日期
        calenderView.viewWillReSize(anchorDate: selectDate)
    }
    
    func getAllbillingDate(){
        let fetchRequest: NSFetchRequest<Billing> = Billing.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        var dateArr = [Date]()
        do{
            CoreDataService.coreDataService.context.reset()
            let Billing = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            for b in Billing {
                dateArr.append(b.date! as Date)
                
            }
        }catch{
            
        }
        billingDate = dateArr
    }
    
    func getBillings(date:Date){
        let fetchRequest: NSFetchRequest<Billing> = Billing.fetchRequest()
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: date)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
//        print(dateFrom)
//        print(dateTo)
        fetchRequest.predicate = NSPredicate(format: "(%@ <= date) AND (date < %@)", argumentArray: [dateFrom, dateTo])
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            CoreDataService.coreDataService.context.reset()
            let Billing = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            billings = []
            incomes = []
            billngMoney = 0
            incomeMoney = 0
            for b in Billing {
                if b.billing_type == 0 {
                    self.billings.append(b)
                    billngMoney += Int(b.money)
                }else{
                    self.incomes.append(b)
                    incomeMoney += Int(b.money)
                }
            }
            self.tableView.reloadData()
        }catch{
            
        }
    }
    
    func setCalenderView(){
        calenderView.minimumLineSpacing = 0
        calenderView.minimumInteritemSpacing = 0
    }
    
    func setupViewOfCalender(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first?.date
        self.formetter.dateFormat = "yyyy"
        self.year.text = "   "+self.formetter.string(from: date!)
        self.formetter.dateFormat = "MMMM"
        self.month.text = "   "+self.formetter.string(from: date!)
    }
    
    func handleCellTextColor(view:JTAppleCell?,cellState:CellState){
        guard let validCell = view as? CustomCell else {return}
        if cellState.isSelected {
            validCell.dateLabel.textColor = calenderView.backgroundColor
        }else{
            if cellState.dateBelongsTo == .thisMonth {
                 validCell.dateLabel.textColor = selectedMonthColor
            }else{
                 validCell.dateLabel.textColor = UIColor.gray
            }
        }
    }
    func handleCellSelected(view:JTAppleCell?,cellState:CellState){
        guard let validCell = view as? CustomCell else {return}
        if cellState.isSelected {
            validCell.selectView.isHidden = false
        }else{
            validCell.selectView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        let destinationNavigationController = segue.destination as! UINavigationController
        if let targetController = destinationNavigationController.topViewController as? inputTableViewController{
            
            if isEdit {
                targetController.billing = editBilling!
                targetController.inputDate = selectDate! as NSDate
                targetController.isEdit = true
            }else{
                targetController.inputDate = selectDate! as NSDate
                targetController.isEdit = false
            }
            
        }
        isEdit = false
        
    }
    
    func initCalenderDate(date:Date) {
        calenderView.viewWillReSize(anchorDate: date)
    }
    
    
    @IBAction func showLeftMenu(_ sender: UIBarButtonItem) {
        openLeft()
        calenderView.viewWillReSize(anchorDate: selectDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if incomes.count > 0{
            self.section = ["收入:\(incomeMoney)","支出:\(billngMoney)"]
        }else{
            self.section = ["支出:\(billngMoney)"]
        }
        return self.section[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if incomes.count > 0{
            self.section = ["收入:\(incomeMoney)","支出:\(billngMoney)"]
        }else{
            self.section = ["支出:\(billngMoney)"]
        }
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.font = year.font
            headerTitle.textLabel?.textColor = year.textColor
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if incomes.count > 0{
            if section == 0{
                return incomes.count
            }else{
                return billings.count
            }
        }else{
            return billings.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainTableViewCell
        if incomes.count > 0{
            if indexPath.section == 0{
                cell.emojiLabel.text = incomes[indexPath.row].money_type_emoji
                cell.noteLabel.text = incomes[indexPath.row].note
                cell.moneyLabel.text = "\(incomes[indexPath.row].money)元"
            }else{
                cell.emojiLabel.text = billings[indexPath.row].money_type_emoji
                cell.noteLabel.text = billings[indexPath.row].note
                cell.moneyLabel.text = "\(billings[indexPath.row].money)元"
            }
        }else{
            cell.emojiLabel.text = billings[indexPath.row].money_type_emoji
            cell.noteLabel.text = billings[indexPath.row].note
            cell.moneyLabel.text = "\(billings[indexPath.row].money)元"
        }
        cell.noteLabel.textColor = year.textColor
        cell.moneyLabel.textColor = year.textColor
        return cell
    }
    
    //刪除方法
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var money = 0
        if incomes.count > 0{
            if indexPath.section == 0 {
                money = 0
                CoreDataService.coreDataService.context.delete(self.incomes[indexPath.row])
                CoreDataService.coreDataService.saveContext()
                self.incomes.remove(at: indexPath.row)
                for i in incomes {
                    money += Int(i.money)
                }
                incomeMoney = money
                self.tableView.reloadData()
//                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top);
            }else{
                money = 0
                CoreDataService.coreDataService.context.delete(self.billings[indexPath.row])
                CoreDataService.coreDataService.saveContext()
                self.billings.remove(at: indexPath.row)
                for i in billings {
                    money += Int(i.money)
                }
                billngMoney = money
                self.tableView.reloadData()
                
//                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top);
            }
        }else{
             money = 0
            CoreDataService.coreDataService.context.delete(self.billings[indexPath.row])
            CoreDataService.coreDataService.saveContext()
            self.billings.remove(at: indexPath.row)
            for i in billings {
                money += Int(i.money)
            }
            billngMoney = money
            self.tableView.reloadData()
//            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top);
        }
        calenderView.reloadData()
    }
    //改變刪除文字
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        isEdit = true
        
        let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        cell.noteLabel.textColor = UIColor(colorWithHexValue: 0x566270)
        cell.moneyLabel.textColor = UIColor(colorWithHexValue: 0x566270)
        if incomes.count > 0{
            if indexPath.section == 0{
                editBilling = incomes[indexPath.row]
            }else{
                editBilling = billings[indexPath.row]
            }
        }else{
            editBilling = billings[indexPath.row]
        }
        performSegue(withIdentifier: "toInput", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("didDeselectRowAt")
        let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        cell.noteLabel.textColor = year.textColor
        cell.moneyLabel.textColor = year.textColor
    }
    
}

//extension JTAppleCalendarViewDataSource
extension ViewController:JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formetter.dateFormat = "yyyy MM dd"
        formetter.timeZone = Calendar.current.timeZone
        formetter.locale = Calendar.current.locale
        
        let startDate = formetter.date(from: "2017 01 01")!
        let endDate = formetter.date(from: "2018 12 31")!
        
        let parateters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parateters
    }
    
}

//extension JTAppleCalendarViewDelegate
extension ViewController:JTAppleCalendarViewDelegate{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        handleCellSelected(view:cell,cellState:cellState)
        handleCellTextColor(view:cell,cellState:cellState)
        cell.markLabel.isHidden = true
        for d in billingDate{
            if d == date {
                cell.markLabel.isHidden = false
            }
        }
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(view:cell,cellState:cellState)
        handleCellTextColor(view:cell,cellState:cellState)
        selectDate = date
        getBillings(date: date)
        tableView.reloadData()
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view:cell,cellState:cellState)
        handleCellTextColor(view:cell,cellState:cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalender(from: visibleDates)
    }
    
    
    
}


