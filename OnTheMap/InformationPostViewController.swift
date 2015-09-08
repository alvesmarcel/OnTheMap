//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for posting student information in the servers using the Parse methods
//  There are "two" implicit screens in this view (Location UI and Link UI). They change between them with alpha configurations.
//
//  BUG: When an alert controller appears, the Cancel button changes to its color set in the Storyboard (not the correct one set programmatically)

import UIKit
import MapKit

class InformationPostViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {

	// MARK: - UIButtons
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	
	// MARK: - UILabels
	
	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var label3: UILabel!
	
	// MARK: - UITextFields
	
	@IBOutlet weak var locationTextField: UITextView!
	@IBOutlet weak var linkTextField: UITextView!
	
	// MARK: - MKMapView
	
	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Class variables
	
	var shouldCleanTextView: Bool!
	var loadingScreen: LoadingScreen!
	var studentInformation = StudentInformation()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Setting the delegates */
		locationTextField.delegate = self
		linkTextField.delegate = self
		
		/* Setting mapView configurations */
		mapView.zoomEnabled = false
		mapView.scrollEnabled = false
		mapView.delegate = self
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		configureLocationUI()
	}
	
	// MARK: - Actions
	
	@IBAction func cancelButtonTouch(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	/* Deals with "Find on the Map" (if) or "Submit" (else) button (they are the same) touch */
	@IBAction func findOnTheMapButtonTouch(sender: AnyObject) {

		/* When button's text is "Find on the Map", the button is dealing with the "first" screen (Location UI) */
		if submitButton.titleLabel?.text == "Find on the Map" {
			
			/* The text view is clean or should be cleaned - so, it should not proceed */
			if shouldCleanTextView == true {
				ErrorDisplay.displayErrorWithTitle("Missing Location", errorDescription: "Must Enter Location", inViewController: self, andDeactivatesLoadingScreen: nil)
			} else {
				
				/* The app will try to post the location and activates the loading screen */
				loadingScreen.setActive(true)
				
				/* The geocoder tries to find a location that was in locationTextField */
				let geocoder = CLGeocoder()
				geocoder.geocodeAddressString(locationTextField.text) { placemarks, error in
					
					/* Geocoder could not find the location */
					if let error = error {
						ErrorDisplay.displayErrorWithTitle("Place Not Found", errorDescription: "Could Not Geocode the String", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
					} else {
						
						/* Location was found by the geocoder - loading screen is off */
						self.loadingScreen.setActive(false)
						
						/* Selects the top result from the geocoder and configure the Link UI (the "second" screen) */
						if let topResult = placemarks[0] as? CLPlacemark {
							self.configureLinkUI()
							
							let placemark = MKPlacemark(placemark: topResult)
							let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 4000, 4000)
							self.mapView.setRegion(region, animated: true)
							self.mapView.addAnnotation(placemark)
							
							/* Complementing student information to be posted */
							self.studentInformation.latitude = placemark.coordinate.latitude as Double
							self.studentInformation.longitude = placemark.coordinate.longitude as Double
							self.studentInformation.mapString = self.locationTextField.text
						}
					}
				}
			}
		}
		
		/* Button's text isn't "Find on the Map" (it is "Submit") - the action should deal with the "second" screen (Link UI)  */
		else {
			
			/* The text view is clean or should be cleaned - so, it should not proceed */
			if shouldCleanTextView == true {
				ErrorDisplay.displayErrorWithTitle("Missing Link", errorDescription: "Must Enter a Link", inViewController: self, andDeactivatesLoadingScreen: nil)
			} else {
				
				if checkLink(linkTextField.text) {
					
					/* The link is valid - set loadingScreen active and try to post link with location */
					loadingScreen.setActive(true)
							
					/* Completing student information to be posted */
					self.studentInformation.mediaURL = self.linkTextField.text
						
					ParseClient.sharedInstance().postStudentLocationWithInformation(self.studentInformation) { success in
						if success {
							
							/* Student information was successful posted - update MapViewController */
							self.loadingScreen.setActive(false)
							self.dismissViewControllerAnimated(true, completion: nil)
							// TODO: Post Notification to update MapViewController
						} else {
							ErrorDisplay.displayErrorWithTitle("Error Posting Location", errorDescription: "Could Not Post Student Location", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
						}
					}
				} else {
					ErrorDisplay.displayErrorWithTitle("Invalid Link", errorDescription: "Invalid Link. Include http(s)://", inViewController: self, andDeactivatesLoadingScreen: nil)
				}
			}
		}
	}
	
	// MARK: - UITextFieldDelegate Methods
	
	/* Cleans text field when needed */
	func textViewDidBeginEditing(textView: UITextView) {
		if shouldCleanTextView == true {
			textView.text = ""
		}
		shouldCleanTextView = false
	}
	
	/* Hides keyboard when return key is touched */
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			
			if textView.text == "" {
				resetTextView()
			}
			
			return false
		}
		return true
	}
	
	// MARK: - UI Helper methods
	
	/* Puts the text field in the initial state according to the text field alpha */
	/* The alpha condition is essential to avoid updating both text fields (correct values are needed to post student location) */
	func resetTextView() {
		dispatch_async(dispatch_get_main_queue()) {
			if self.linkTextField.alpha > 0 {
				self.linkTextField.text = "Enter a Link to Share Here"
			} else {
				self.locationTextField.text = "Enter Your Location Here"
			}
		}
		shouldCleanTextView = true
	}
	
	/* Configures the UI to present the "location screen" */
	func configureLocationUI() {
		dispatch_async(dispatch_get_main_queue()) {
			self.label1.alpha = 1.0
			self.label2.alpha = 1.0
			self.label3.alpha = 1.0
			
			self.linkTextField.alpha = 0.0
			
			self.mapView.alpha = 0.0
			
			self.submitButton.setTitle("Find on the Map", forState: .Normal)
			self.cancelButton.titleLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.59, alpha: 1.0)
			
			self.view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
		}
		resetTextView()
	}
	
	/* Configures the UI to presente the "link screen" */
	func configureLinkUI() {
		dispatch_async(dispatch_get_main_queue()) {
			self.label1.alpha = 0.0
			self.label2.alpha = 0.0
			self.label3.alpha = 0.0
			
			self.linkTextField.alpha = 1.0
			
			self.mapView.alpha = 1.0
			
			self.submitButton.setTitle("Submit", forState: .Normal)
			self.cancelButton.titleLabel?.textColor = UIColor.whiteColor()
			
			self.view.backgroundColor = UIColor(red: 0.29, green: 0.57, blue: 0.75, alpha: 1.0)
		}
		resetTextView()
	}
	
	// MARK: - Helper methods
	
	/* Checks if a link is valid or not - "http(s)://" is needed */
	func checkLink (urlString: String?) -> Bool {
		if let urlString = urlString {
			if let url = NSURL(string: urlString) {
				return UIApplication.sharedApplication().canOpenURL(url)
			}
		}
		return false
	}
}