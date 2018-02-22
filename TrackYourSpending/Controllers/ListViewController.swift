//
//  ListViewController.swift
//  TestSlideMenu
//
//  Created by 江宗翰 on 2018/1/11.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import UIKit
import CoreData
import EFCountingLabel
class ListViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var incomeLabel: EFCountingLabel!
    @IBOutlet weak var expenseLabel: EFCountingLabel!
    @IBOutlet weak var countLabel: EFCountingLabel!
    
    var billings = [Billing]()
    
    var nowDate = Date()
    var dateModSegmentType = 0
    var formetter = DateFormatter()
    var formetter2 = DateFormatter()
    let dateFunction = DateFunction()
    var dateSection = [NSDate:[Billing]]()
    var sectionArr = [NSDate]()
    var expense:Int32 = 0
    var income:Int32 = 0
    
    var dateFrom:Date = Date()
    var dateTo:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        formetter.dateFormat = "yyyy年MM月"
        formetter2.dateFormat = "yyyy年MM月dd日"
//        changeDate()
    }

    override func viewDidLayoutSubviews() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        changeDate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func chageDateRange(){
        if dateModSegmentType == 0{
            dateFrom = dateFunction.startOfCurrentMonth(date: nowDate)
            dateTo = dateFunction.endOfCurrentMonth(date: nowDate, returnEndTime: true)
        }else{
            dateFrom = dateFunction.startOfCurrentYear(date: nowDate)
            dateTo = dateFunction.endOfCurrentYear(date: nowDate, returnEndTime: true)
        }
        print(dateFrom)
        print(dateTo)
    }
    
    func getBillings(){
        let fetchRequest: NSFetchRequest<Billing> = Billing.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "(%@ <= date) AND (date < %@)", argumentArray: [dateFrom, dateTo])
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do{
            CoreDataService.coreDataService.context.reset()
            let billings = try CoreDataService.coreDataService.context.fetch(fetchRequest)
//            self.billings = billings
            dateSection = [:]
            sectionArr = []
            expense = 0
            income = 0
            for billing in billings {
                if dateSection[billing.date!] != nil {
                    dateSection[billing.date!]?.append(billing)
                }else{
                    dateSection[billing.date!] = [billing]
                    sectionArr.append(billing.date!)
                }
                if billing.billing_type == 0{
                    expense += billing.money
                }else{
                    income += billing.money
                }
            }
            print(expense)
            print(income)
        }catch{
            
        }
        tableView.reloadData()
    }
    
    
    @IBAction func openLeftMenu(_ sender: UIBarButtonItem) {
        openLeft()
    }
    
    @IBAction func addDate(_ sender: Any) {
        if dateModSegmentType == 0{
            nowDate = Calendar.current.date(byAdding: .month, value: 1, to: nowDate)!
        }else{
            nowDate = Calendar.current.date(byAdding: .year, value: 1, to: nowDate)!
        }
        changeDate()
    }
    @IBAction func backDate(_ sender: Any) {
        if dateModSegmentType == 0{
            nowDate = Calendar.current.date(byAdding: .month, value: -1, to: nowDate)!
        }else{
            nowDate = Calendar.current.date(byAdding: .year, value: -1, to: nowDate)!
        }
        changeDate()
        
    }
    
    
    @IBAction func dateModSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            formetter.dateFormat = "yyyy年MM月"
            dateModSegmentType = 0
        }else{
            formetter.dateFormat = "yyyy年"
            dateModSegmentType = 1
        }
        changeDate()
    }
    
    func changeDate(){
        
        chageDateRange()
        getBillings()
        incomeLabel.method = .easeInOut
        incomeLabel.format = "%d%元"
        incomeLabel.countFrom(0, to: CGFloat(income), withDuration: 1)
        
        
        expenseLabel.method = .easeInOut
        expenseLabel.format = "%d%元"
        expenseLabel.countFrom(0, to: CGFloat(expense), withDuration: 1)
        
        countLabel.method = .easeInOut
        countLabel.format = "%d%元"
        countLabel.countFrom(0, to: CGFloat(income-expense), withDuration: 1)
        
        dateLabel.text = formetter.string(from: nowDate)
    }
}


extension ListViewController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(sectionArr.count)
        return sectionArr.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formetter2.string(from: sectionArr[section] as Date)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = dateLabel.textColor
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateSection[sectionArr[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let billings = dateSection[sectionArr[indexPath.section]]!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainTableViewCell
        
        cell.emojiLabel.text = billings[indexPath.row].money_type_emoji
        cell.noteLabel.text = billings[indexPath.row].note
        cell.moneyLabel.text = "\(billings[indexPath.row].money)元"
//        print("section:\(indexPath.section)  row:\(indexPath.row)  note:\(cell.noteLabel.text)")
        return cell
    }
    //刪除方法
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        CoreDataService.coreDataService.context.delete(dateSection[sectionArr[indexPath.section]]![indexPath.row])
        CoreDataService.coreDataService.saveContext()
        dateSection[sectionArr[indexPath.section]]!.remove(at: indexPath.row)
        tableView.reloadData()
    }
    //改變刪除文字
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
}
