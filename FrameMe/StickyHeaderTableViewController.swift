//
//  StickyHeaderTableTableViewController.swift
//  FrameMe
//
//  Created by Suraj Pathak on 1/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

class StickyHeaderTableViewController: UITableViewController {

    @IBOutlet var parallaxHeader: PGParallaxTableViewHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parallaxHeader = tableView.tableHeaderView as! PGParallaxTableViewHeader
        tableView.tableHeaderView = nil
        tableView.addSubview(parallaxHeader)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.contentInset = UIEdgeInsets(top: parallaxHeader.frame.height, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -parallaxHeader.frame.height)
        
        parallaxHeader.tableView = self.tableView
        parallaxHeader.referenceHeight = parallaxHeader.frame.height
        
        parallaxHeader.updateHeaderView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = "Table view cell section: \(indexPath.section), row: \(indexPath.row)"

        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        parallaxHeader.updateHeaderView()
    }

}
