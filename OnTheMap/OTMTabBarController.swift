//
//  CustomTabBarController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
	
	var studentLocations: [StudentLocation] = [StudentLocation]()
	let dataDownloadStartedNotification = NSNotification(name: "DataDownloadStartedNotification", object: nil)
	let dataDownloadFinishedNotification = NSNotification(name: "DataDownloadFinishedNotification", object: nil)
	
	override func viewDidLoad() {
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "callInformationPostViewController:")
		self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
	
	func refreshLocations(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotification(self.dataDownloadStartedNotification)
		ParseClient.sharedInstance().getStudentsLocations(100, skip: 0) { studentLocations, error in
			if let error = error {
				self.displayError(error.localizedDescription)
			} else {
				if let locations = studentLocations {
					self.studentLocations = locations
					NSNotificationCenter.defaultCenter().postNotification(self.dataDownloadFinishedNotification)
				} else {
					println("Unexpected Error")
				}
			}
		}
	}
	
	@IBAction func logoutTouch(sender: AnyObject) {
		println("REALIZAR LOGOUT")
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func callInformationPostViewController(sender: AnyObject) {
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostViewController") as! UIViewController
		self.presentViewController(controller, animated: true, completion: nil)
	}
	
	func displayError(errorString: String?) {
		dispatch_async(dispatch_get_main_queue()) {
			if let errorString = errorString {
				let alertController = UIAlertController(title: "Get Locations Error", message: "An error has ocurred\n" + errorString, preferredStyle: .Alert)
				let DismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
				alertController.addAction(DismissAction)
				self.presentViewController(alertController, animated: true) {}
			}
		}
	}
}