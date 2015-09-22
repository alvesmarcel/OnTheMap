//
//  TopFiveViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/7/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for exibiting the top 5 countries with student locations posted
//  The view exhibits some labels (countryLabels) with the country rank
//  THIS VIEW USES "A LOT" OF NETWORK CALLS WHEN COMPARED TO THE OTHERS DUE TO THE getTopFiveCountries() METHOD

import UIKit
import MapKit

class TopFiveViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet var countryLabels: [UILabel]!
	
	// MARK: - Class variables

	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.parentViewController!.view)
	}
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the tableView when student information is saved */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "getTopFiveCountries", name: NotificationNames.StudentLocationsSavedNotification, object: nil)
		
		/* Ensure the top 5 is updated when the view appears - this consumes network data and may take a while */
		getTopFiveCountries()
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		/* Removing observers */
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Notification activated methods
	
	/* Realizes a reverseGeocodeLocation for every student to discover their countries */
	/* This method takes a while because it performs at least 100 calls using the network */
	func getTopFiveCountries() {
		var countryCountDictionary = [String:Int]()
		var count = 0
		
		loadingScreen.setActive(true)
		
		for studentInformation in ParseClient.sharedInstance().studentsInformation {
			let location = CLLocation(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
			
			CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
				
				if error != nil {
					ErrorDisplay.displayErrorWithTitle("Error Checking Countries", errorDescription: "Could not download all locations", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
				} else {
					let place = placemark[0] as! CLPlacemark
					if countryCountDictionary[place.country] == nil {
						countryCountDictionary[place.country] = 1
					} else {
						countryCountDictionary[place.country] = countryCountDictionary[place.country]! + 1
					}
				}
				
				/* Calls updateView() when the last country is checked */
				count = count + 1
				if count == ParseClient.sharedInstance().studentsInformation.count {
					self.updateViewWithCountries(countryCountDictionary)
					self.loadingScreen.setActive(false)
				}
			}
		}
	}
	
	// MARK: UI Helper methods
	
	/* Updates the view to show the rank (top 5) of countries with most student locations posted */
	func updateViewWithCountries(countryCountDictionary: [String:Int]) {
		let sortedCountries = Array(countryCountDictionary).sorted({$0.1 > $1.1})
		for i in 0...4 {
			dispatch_async(dispatch_get_main_queue()){
				self.countryLabels[i].text = "\(i+1). \(sortedCountries[i].0) (\(sortedCountries[i].1))"
			}
		}
	}
}
