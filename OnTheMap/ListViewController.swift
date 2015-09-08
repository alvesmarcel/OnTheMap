//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/28/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for the List View (Table View).
//  The table is filled with students first and last names.
//  When the table cell is touched, the mediaURL link associated with the student is opened in Safari.
//  All the UI methods are realized by MapViewController.

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Outlets
	
	@IBOutlet weak var tableView: UITableView!
	
	// MARK: - Lifecycle
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the table view when the data is completely downloaded again using the refresh button */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView:", name: "StudentLocationsSavedNotification", object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Notification activated methods
	
	func updateTableView(sender: AnyObject) {
		self.tableView.reloadData()
	}
	
	// MARK: - UITableViewDataSource methods
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		/* Get cell type */
		let cellReuseIdentifier = "ListViewTableCell"
		let student = ParseClient.sharedInstance().studentsInformation[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
		
		/* Set cell defaults */
		cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
		cell.imageView!.image = UIImage(named: "pin")
		cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ParseClient.sharedInstance().studentsInformation.count
	}
	
	// MARK: - UITableViewDelegate methods
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let app = UIApplication.sharedApplication()
		app.openURL(NSURL(string: ParseClient.sharedInstance().studentsInformation[indexPath.row].mediaURL)!)
	}
}