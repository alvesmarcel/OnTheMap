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
	var countryCountDictionary = [String:Int]()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.parentViewController!.view)
	}
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the tableView when student information is saved */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "getTopFiveCountries", name: NotificationNames.StudentLocationsSavedNotification, object: nil)
		
		/* Ensure the top 5 is updated when the view appears - this consumes network data and may take a while */
		getTopFiveCountries(0)
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		/* Removing observers */
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Notification activated methods
	
	/* Realizes a reverseGeocodeLocation for every student to discover their countries */
	/* This method takes a while because it performs at least 200 calls using the network */
	func getTopFiveCountries(count: Int) {

		loadingScreen.setActive(true)
		
		let studentInformation = ParseClient.sharedInstance().studentsInformation[count]
		let location = CLLocation(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
		
		CLGeocoder().reverseGeocodeLocation(location) { placemark, error in
			
			if error != nil {
				ErrorDisplay.displayErrorWithTitle("Error Checking Countries", errorDescription: "Could not download all locations", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
			} else {
				let place = (placemark as [CLPlacemark]!)[0] as CLPlacemark!
				
				/* Verifies if the country is not nil (e.g. Pacific Ocean) */
				if place.country != nil {
					
					if self.countryCountDictionary[place.country!] == nil {
						
						/* If the country is not found in the dictionary, the count should be initialized for that country */
						self.countryCountDictionary[place.country!] = 1
					} else {
						
						/* Increment country count */
						self.countryCountDictionary[place.country!] = self.countryCountDictionary[place.country!]! + 1
					}
				}
				
				if count < 40 {
					
					print(count)
					
					/* Recursive call getTopFiveCountries to get one more country */
					self.getTopFiveCountries(count + 1)
				} else {
					
					/* Calls updateView() when the last country is checked */
					self.updateViewWithCountries(self.countryCountDictionary)
					self.loadingScreen.setActive(false)
				}
			}
		}
	}
	
	// MARK: UI Helper methods
	
	/* Updates the view to show the rank (top 5) of countries with most student locations posted */
	func updateViewWithCountries(countryCountDictionary: [String:Int]) {
		print(countryCountDictionary)
		let sortedCountries = Array(countryCountDictionary).sort({$0.1 > $1.1})
		print(sortedCountries)
		for i in 0...4 {
			dispatch_async(dispatch_get_main_queue()){
				self.countryLabels[i].text = "\(i+1). \(sortedCountries[i].0) (\(sortedCountries[i].1))"
			}
		}
	}
}
