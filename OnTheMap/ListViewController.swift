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
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		configureUI()
		if ParseClient.sharedInstance().studentsInformation.count == 0 {
			refreshLocations(self)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		
		super.viewWillAppear(animated)
		
		// TODO: REMOVE THESE BUTTONS FROM HERE
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "callInformationPostViewController:")
		self.tabBarController!.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
	
	func refreshLocations(sender: AnyObject?) {
		loadingScreenSetActive(true)
		ParseClient.sharedInstance().getStudentsLocationsWithLimit(100, skip: 0) { studentLocations, error in
			if let error = error {
				self.displayError(error.localizedDescription)
			} else {
				if let locations = studentLocations {
					dispatch_async(dispatch_get_main_queue()) {
						self.tableView.reloadData()
						self.loadingScreenSetActive(false)
					}
					println("Students Locations saved")
				} else {
					println("Unexpected Error")
				}
			}
		}
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
	
	// MARK: - UI Helper Methods
	
	func displayError(errorString: String?) {
		dispatch_async(dispatch_get_main_queue()) {
			self.loadingScreenSetActive(false)
			if let errorString = errorString {
				let alertController = UIAlertController(title: "Get Locations Error", message: "An error has ocurred\n" + errorString, preferredStyle: .Alert)
				let DismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
				alertController.addAction(DismissAction)
				self.presentViewController(alertController, animated: true) {}
			}
		}
	}
	
	func loadingScreenSetActive(active: Bool) {
		if active {
			loadingView.hidden = false
			activityIndicatorView.startAnimating()
		} else {
			loadingView.hidden = true
			activityIndicatorView.stopAnimating()
		}
	}
	
	/* Performs some UI configuration */
	func configureUI() {
		
		/* Loading screen configuration */
		activityIndicatorView.hidesWhenStopped = true
		loadingScreenSetActive(false)
	}
}