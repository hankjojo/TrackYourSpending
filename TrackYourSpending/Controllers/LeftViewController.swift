//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case main = 0
    case list
    case chart
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var mainColor = UIColor(colorWithHexValue: 0x566270)
    
    var menus = ["首頁","清單","圖表"]
    var viewController: UIViewController!
    var chartViewController: UIViewController!
    var listViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.viewController = UINavigationController(rootViewController: viewController)
        
        let ChartStoryboard = UIStoryboard(name: "Chart", bundle: nil)
        let chartViewController = ChartStoryboard.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        self.chartViewController = UINavigationController(rootViewController: chartViewController)
        
        let listStoryboard = UIStoryboard(name: "List", bundle: nil)
        let listViewController = listStoryboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        self.listViewController = UINavigationController(rootViewController: listViewController)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        print("changeViewController")
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewController, close: true)
        case .chart:
            self.slideMenuController()?.changeMainViewController(self.chartViewController, close: true)
        case .list:
            self.slideMenuController()?.changeMainViewController(self.listViewController, close: true)
        }
    }
}

extension LeftViewController:UITableViewDataSource,UITableViewDelegate{
    //tableView的數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    //tableView的值
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = menus[indexPath.row]
        cell?.textLabel?.font = nameLabel.font
        if indexPath.row == 0 {
            cell?.textLabel?.textColor = mainColor
        }else{
            cell?.textLabel?.textColor = nameLabel.textColor
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
    }
    
    
    
    //選取tableview的項目觸發
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.textLabel?.textColor = mainColor
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.textLabel?.textColor = nameLabel.textColor
    }
    
}



