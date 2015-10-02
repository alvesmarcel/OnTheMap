//
//  TopFiveViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/7/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for exibiting the top 5 countries with student locations posted
//  The view exhibits some labels (countryLabels) with the country rank
//
//  Only the last 40 students (first 40 in the array) are used to generate the Top 5
//  - This is due to the fact that Apple seems not to allow too many calls to CLGeocoder().reverseGeocodeLocation()
//
//  THIS VIEW USES "A LOT" OF NETWORK CALLS WHEN COMPARED TO THE OTHERS DUE TO THE getTopFiveCountries() METHOD

import UIKit
import MapKit

class TopFiveViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet var countryLabels: [UILabel]!
	@IBOutlet weak var top5Label: UILabel!
	
	// MARK: - Class variables

	var loadingScreen: LoadingScreen!
	var countryCountDictionary = [String:Int]()
	var numberOfLabels = 5
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Checking if it is iPhone 4S to adjust TopFive functionality */
		if UIScreen.mainScreen().bounds.size.height < 568.0 {
			dispatch_async(dispatch_get_main_queue()) {
				self.countryLabels[3].text = ""
				self.countryLabels[4].text = ""
				self.top5Label.text = "Top 3"
			}
			numberOfLabels = 3
		}
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.parentViewController!.view)
		
		/* getTopFiveCountries() can be called only once due to reverseGeocodeLocation() limitations */
		if countryLabels[0].text! == "1." {
			getTopFiveCountries(0)
		}
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
		
		let sortedCountries = Array(countryCountDictionary).sort({$0.1 > $1.1})
		let loopRange = min(numberOfLabels - 1, sortedCountries.count) // Prevents accessing array out of bounds
		for i in 0...loopRange {
			dispatch_async(dispatch_get_main_queue()){
				self.countryLabels[i].text = "\(i+1). \(sortedCountries[i].0) (\(sortedCountries[i].1))"
			}
		}
	}
}
