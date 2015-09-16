//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/9/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is the Parent View Controller of MapViewController, ListViewController and TopFiveViewController
//  The objective of this class is to handle the actions of Navigation Item Buttons
//  This class also calls methods to update students' information (studentsInformation array)

import UIKit

class TabBarViewController: UITabBarController {
	
	// MARK: - Class variables
	
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Adding the left bar button (logout) to the navigation bar */
		let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout:")
		self.navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "pinBarButtonTouch:")
		self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
		
		/* When the view is loaded, the locations are fetched from the server and the view updated */
		refreshLocations(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the data when InformationPostViewController is dismissed */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocations:", name: NotificationNames.ShouldUpdateDataNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		/* Removing observers */
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Actions
	
	/* Realizes the logout and dismiss the view if the logout is successful */
	func logout(sender: AnyObject) {
		// TODO: Implement Facebook Logout
		
		loadingScreen.setActive(true)
		
		/* Logout with Udacity */
		UdacityClient.sharedInstance().deauthenticateWithUdacity() { result, error in
			
			if let error = error {
				ErrorDisplay.displayErrorWithTitle("Logout Error", errorDescription: error.localizedDescription, inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
			} else {
				println("Udacity logout successful")
				dispatch_async(dispatch_get_main_queue()) {
					self.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
	}
	
	/* pinBarButtonItem action - Verifies if the student has already posted the information */
	/* Then calls callInformationPostViewControllerWithDictionary:toUpdate: with the correct parameters */
	func pinBarButtonTouch(sender: AnyObject) {
		loadingScreen.setActive(true)
		UdacityClient.sharedInstance().getPublicUserData() { result, error in
			
			if error != nil {
				ErrorDisplay.displayErrorWithTitle("Error Getting Student Information", errorDescription: "Could Not Get Student Information from Server", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
			} else {
				if let dictionary = result {
					
					/* Checks if the information/location was already posted */
					let alreadyPosted = ParseClient.sharedInstance().studentsInformation.filter{$0.uniqueKey == dictionary[UdacityClient.JSONResponseKeys.Key] as! String}
					
					if alreadyPosted.count > 0 {
						
						/* Information was already posted: alertController gives option to Overwrite or Cancel */
						dispatch_async(dispatch_get_main_queue()) {
							let firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
							let lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
							let alertController = UIAlertController(title: "Location Already Posted", message: "User \"\(firstName) \(lastName)\" has already posted a student location. Would you like to overwrite the location?", preferredStyle: .Alert)
							
							let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { action in
								self.callInformationPostViewControllerWithDictionary(dictionary, toUpdate: alreadyPosted[0].objectID)
							}
							let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
							
							alertController.addAction(overwriteAction)
							alertController.addAction(cancelAction)
							self.presentViewController(alertController, animated: true) {}
						}
					} else {
						
						/* Information wasn't posted yet: call the next view controller saying that it is not to update (but to post) */
						self.callInformationPostViewControllerWithDictionary(dictionary, toUpdate: nil)
					}
					self.loadingScreen.setActive(false)
				}
			}
		}
	}
	
	/* Fetchs locations from the server and updates the mapView - refreshBarButtonItem action */
	func refreshLocations(sender: AnyObject?) {
		loadingScreen.setActive(true)
		ParseClient.sharedInstance().getStudentsLocationsWithLimit(100, skip: 0) { studentLocations, error in
			if let error = error {
				ErrorDisplay.displayErrorWithTitle("Could Not Get Locations", errorDescription: error.localizedDescription, inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
			} else {
				self.loadingScreen.setActive(false)
				NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.StudentLocationsSavedNotification, object: nil)
				println("Students Locations saved")
			}
		}
	}
	
	// MARK: - Helper methods
	
	/* Calls Information Post View Controller after pinBarButtonItem is touched */
	func callInformationPostViewControllerWithDictionary(dictionary: [String:AnyObject], toUpdate objectID: String?) {
		dispatch_async(dispatch_get_main_queue()) {
			/* Student information to pass to the next controller */
			var studentInformation = StudentInformation()
			studentInformation.uniqueKey = UdacityClient.sharedInstance().accountKey as! String
			studentInformation.firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
			studentInformation.lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
			
			/* Calling the next controller and turning off the loading screen */
			let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostViewController") as! InformationPostViewController
			controller.studentInformation = studentInformation
			controller.objectID = objectID
			self.presentViewController(controller, animated: true, completion: nil)
		}
	}
}
