//
//  DateFunction.swift
//  TestSlideMenu
//
//  Created by 江宗翰 on 2018/1/11.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import Foundation

class DateFunction {
    //本月開始日期
    func startOfCurrentMonth(date:Date) -> Date {
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(
            Set<Calendar.Component>([.year, .month]), from: date)
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }
    
    //本月結束日期
    func endOfCurrentMonth(date:Date,returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfMonth =  calendar.date(byAdding: components, to: startOfCurrentMonth(date: date))!
        return endOfMonth
    }
    //本年開始日期
    func startOfCurrentYear(date:Date) -> Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(Set<Calendar.Component>([.year]), from: date)
        let startOfYear = calendar.date(from: components)!
        return startOfYear
    }
    
    //本年結束日期
    func endOfCurrentYear(date:Date,returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.year = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfYear = calendar.date(byAdding: components, to: startOfCurrentYear(date:date))!
        return endOfYear
    }
}
