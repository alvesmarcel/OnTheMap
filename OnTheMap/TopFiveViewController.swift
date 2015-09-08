//
//  TopFiveViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/7/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for exibiting the top 5 countries with student locations posted
//  The view exhibits some labels (countryLabels) with the country rank

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
		loadingScreen = LoadingScreen(view: self.view)
		
		/* Get top five countries to initialize the screen */
		getTopFiveCountries()
	}
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the table view when the data is completely downloaded again using the refresh button */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "getTopFiveCountries", name: "StudentLocationsSavedNotification", object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - Notification activated methods
	
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
	
	func updateViewWithCountries(countryCountDictionary: [String:Int]) {
		let sortedCountries = Array(countryCountDictionary).sorted({$0.1 > $1.1})
		for i in 0...4 {
			dispatch_async(dispatch_get_main_queue()){
				self.countryLabels[i].text = "\(i+1). \(sortedCountries[i].0) (\(sortedCountries[i].1))"
			}
		}
	}
}
