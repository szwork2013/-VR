//
//  NewsListController.swift
//  盗梦极客VR
//
//  Created by wl on 4/24/16.
//  Copyright © 2016 wl. All rights reserved.
//

import UIKit
import SVProgressHUD
import MJRefresh

class NewsListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadLabel: UILabel!
    
    var URL: String = ""
    
    var newsModelArray: [NewsModel] = [] {
        didSet {
            tableView.hidden = false
            tableView.reloadData()
        }
    }
    
    var parameters: [String: AnyObject] {
        return [
            "page": newsModelArray.count / 10
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadNetworkData()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        loadNetworkData()
    }
}

extension NewsListController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.hidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadNetworkData))
    }
    func loadNetworkData() {
        
        if newsModelArray.count == 0 {
            self.reloadLabel.hidden = true
            SVProgressHUD.showMessage("正在玩命加载")
        }

        fetchJsonFromNet(URL, parameters)
            .map { jsonToModelArray( $0["posts"], initial: NewsModel.init) }
            .operation { result in
                self.tableView.mj_footer.endRefreshing()
                switch result {
                case .Success(let v):
                    SVProgressHUD.dismiss()
                    self.newsModelArray += v
                case .Failure(_):
                    SVProgressHUD.showError("网络异常，请稍后尝试")
                    self.reloadLabel.hidden = false
                }
        }
    }
}

extension NewsListController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModelArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsCell
        let model = newsModelArray[indexPath.row]
        cell.configure(NewsCellViewModel(model: model))
        return cell
    }
}