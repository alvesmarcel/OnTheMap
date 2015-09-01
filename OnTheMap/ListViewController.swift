//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/28/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.tableView.reloadData()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		/* Get cell type */
		let cellReuseIdentifier = "ListViewTableCell"
		let student = ParseClient.sharedInstance().studentLocations[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
		
		/* Set cell defaults */
		cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
		cell.imageView!.image = UIImage(named: "pin")
		cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ParseClient.sharedInstance().studentLocations.count
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
}