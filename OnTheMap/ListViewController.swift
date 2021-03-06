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

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Outlets
	
	@IBOutlet weak var tableView: UITableView!
	
	// MARK: - Lifecycle
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the tableView when student information is saved */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView:", name: NotificationNames.StudentLocationsSavedNotification, object: nil)
		
		/* Ensure tableView is updated when the view appears - this doesn't consume network data */
		updateTableView(self)
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		/* Removing observers */
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - UITableViewDataSource methods
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		/* Get cell type */
		let cellReuseIdentifier = "ListViewTableCell"
		let student = ParseClient.sharedInstance().studentsInformation[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! CustomTableViewCell!
		
		/* Set cell defaults */
		cell.studentNameLabel.text = "\(student.firstName) \(student.lastName)"
		cell.studentLocationLabel.text = "\(student.mapString)"
		cell.studentLinkLabel.text = "\(student.mediaURL)"
		cell.studentImage.image = UIImage(named: "pin")
		cell.studentImage.contentMode = UIViewContentMode.Center

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
	
	// MARK: - Helper methods
	
	/* Takes the student locations in the shared instance of ParseClient and updates the table */
	func updateTableView(sender: AnyObject?) {
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
}