//
//  ChartViewController.swift
//  TestSlideMenu
//
//  Created by 江宗翰 on 2018/1/9.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import UIKit
import Charts
import CoreData
class ChartViewController: UIViewController {
    
    let formetter = DateFormatter()
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var dateLabel: UILabel!
    let dateFunction = DateFunction()
    var textArr = [String]()
    var moneyArr = [Double]()
    
    var noewDate:Date = Date()
    var segmentMod = 0;
    var selectMod = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "圖表"
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        pieChart.entryLabelColor = .white
        pieChart.tintColor = .white
        pieChart.noDataTextColor = .white
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        pieChart.holeColor = UIColor.clear
        pieChart.chartDescription?.text = ""
        
        
        formetter.dateFormat = "yyyy年MM月"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDate(mod:0)
    }
    
    /*   mod 0 取第一次
          1 下個月
          2 上個月
          3 下一年
          4 上一年
    */
    func getDate(mod:Int){
        if mod == 0{
            dateLabel.text = formetter.string(from: noewDate)
            noewDate = formetter.date(from: dateLabel.text!)!
        }else if mod == 1{
            noewDate = Calendar.current.date(byAdding: .month, value: 1, to: noewDate)!
        }else if mod == 2{
            noewDate = Calendar.current.date(byAdding: .month, value: -1, to: noewDate)!
        }else if mod == 3{
            noewDate = Calendar.current.date(byAdding: .year, value: 1, to: noewDate)!
        }else if mod == 4{
            noewDate = Calendar.current.date(byAdding: .year, value: -1, to: noewDate)!
        }
        getBillingMoneyType(date: noewDate)
        getBillings(date: noewDate)
        setChart(dataPoints: textArr, values: moneyArr)
        dateLabel.text = formetter.string(from: noewDate)
    }
    
    @IBAction func addDate(_ sender: Any) {
        if segmentMod == 0{
            getDate(mod:1)
        }else{
            getDate(mod:3)
        }
    }
    @IBAction func backDate(_ sender: Any) {
        if segmentMod == 0{
            getDate(mod:2)
        }else{
            getDate(mod:4)
        }
    }
    
    
    func getBillingMoneyType(date:Date){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Billing")
        
        var dateFrom:Date
        var dateTo:Date
        
        if segmentMod == 0 {
            dateFrom = dateFunction.startOfCurrentMonth(date:date)
            dateTo = dateFunction.endOfCurrentMonth(date:date,returnEndTime: true)
        }else{
            dateFrom = dateFunction.startOfCurrentYear(date:date)
            dateTo = dateFunction.endOfCurrentYear(date:date,returnEndTime: true)
        }
        if selectMod == 0 {
            fetchRequest.propertiesToFetch = ["money_type"]
        }else{
            fetchRequest.propertiesToFetch = ["mood_emoji"]
        }
        fetchRequest.predicate = NSPredicate(format: "billing_type = 0 AND (%@ <= date) AND (date < %@)", argumentArray: [dateFrom, dateTo])
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        textArr = []
        do{
            CoreDataService.coreDataService.context.reset()
            let Billing = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            for b in Billing {
                let bs = b as! [String:String]
                if selectMod == 0 {
                    textArr.append(bs["money_type"]!)
                }else{
                    textArr.append(bs["mood_emoji"]!)
                }
            }
        }catch{
            
        }
        
        
    }
    
    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            formetter.dateFormat = "yyyy年MM月"
            getDate(mod:0)
            segmentMod = 0
            getBillingMoneyType(date: noewDate)
            getBillings(date: noewDate)
            setChart(dataPoints: textArr, values: moneyArr)
        }else{
            formetter.dateFormat = "yyyy年"
            getDate(mod:0)
            segmentMod = 1
            getBillingMoneyType(date: noewDate)
            getBillings(date: noewDate)
            setChart(dataPoints: textArr, values: moneyArr)
        }
    }
    
    @IBAction func openLeftMenu(_ sender: UIBarButtonItem) {
        openLeft()
    }
    

    @IBAction func typeSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            selectMod = 0
            getBillingMoneyType(date: Date())
            getBillings(date: Date())
            setChart(dataPoints: textArr, values: moneyArr)
        }else{
            selectMod = 1
            getBillingMoneyType(date: noewDate)
            getBillings(date: noewDate)
            setChart(dataPoints: textArr, values: moneyArr)
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        pieChart.reloadInputViews()
        var dataEntries: [ChartDataEntry] = []
        dataEntries.removeAll()
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            if i == 0 {
                colors.append(UIColor(colorWithHexValue: 0xEB6764))
            }else if i == 1 {
                colors.append(UIColor(colorWithHexValue: 0x4FC6ED))
            }else if i == 2 {
                colors.append(UIColor(colorWithHexValue: 0x12C4A5))
            }else if i == 3 {
                colors.append(UIColor(colorWithHexValue: 0xFFD972))
            }else if i == 4 {
                colors.append(UIColor(colorWithHexValue: 0xFD8F4C))
            }else{
                let red = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue = Double(arc4random_uniform(256))
                
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }
        }
        
        pieChartDataSet.colors = colors
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        //改pieChart裡面的數字不顯示小數點
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        pieChart.data = pieChartData
        pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
        
        
    }
    
    func getBillings(date:Date){
        let fetchRequest: NSFetchRequest<Billing> = Billing.fetchRequest()
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        var dateFrom:Date
        var dateTo:Date
        if segmentMod == 0 {
            dateFrom = dateFunction.startOfCurrentMonth(date:date)
            dateTo = dateFunction.endOfCurrentMonth(date:date,returnEndTime: true)
        }else{
            dateFrom = dateFunction.startOfCurrentYear(date:date)
            dateTo = dateFunction.endOfCurrentYear(date:date,returnEndTime: true)
        }
        print(dateFrom)
        print(dateTo)
        fetchRequest.predicate = NSPredicate(format: "billing_type = 0 AND (%@ <= date) AND (date < %@)", argumentArray: [dateFrom, dateTo])
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            moneyArr = Array(repeating: 0, count: textArr.count)
            CoreDataService.coreDataService.context.reset()
            let Billing = try CoreDataService.coreDataService.context.fetch(fetchRequest)
            
            for b in Billing {
                var flag = 0
                
                for i in textArr {
                    if selectMod == 0 {
                        if b.money_type == i {
                            moneyArr[flag] += Double(b.money)
                            break
                        }
                        flag += 1
                    }else{
                        if b.mood_emoji == i {
                            moneyArr[flag] += 1
                            break
                        }
                        flag += 1
                    }
                    
                }
            }
        }catch{
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
