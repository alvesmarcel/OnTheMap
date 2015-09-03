//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

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
	@IBOutlet weak var map: MKMapView!
	
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// MARK: - Helper variables
	var shouldCleanTextView: Bool!
	
	var studentInformation = [String : AnyObject]()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		locationTextField.delegate = self
		linkTextField.delegate = self
		
		activityIndicatorView.hidesWhenStopped = true
		loadingScreenSetActive(false)
		
		map.zoomEnabled = false
		map.scrollEnabled = false
		map.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		configureLocationUI()
	}
	
	// MARK: - Actions
	@IBAction func cancelButtonTouch(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
		studentInformation[ParseClient.JSONResponseKeys.UniqueKey] = UdacityClient.sharedInstance().accountKey
		studentInformation[ParseClient.JSONResponseKeys.MapString] = locationTextField.text
		studentInformation[ParseClient.JSONResponseKeys.MediaURL] = linkTextField.text
		
		if submitButton.titleLabel?.text == "Find on the Map" {
			if shouldCleanTextView == true {
				displayError("Must Enter Location")
			} else {
				//loadingScreenSetActive(true)
				
				let geocoder = CLGeocoder()
				geocoder.geocodeAddressString(locationTextField.text) { placemarks, error in
					if let error = error {
						self.displayError("Could Not Geocode the String")
					} else {
						if let topResult = placemarks[0] as? CLPlacemark {
							self.configureLinkUI()
							
							let placemark = MKPlacemark(placemark: topResult)
							let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 4000, 4000)
							self.map.setRegion(region, animated: true)
							self.map.addAnnotation(placemark)
							
					
							self.studentInformation[ParseClient.JSONResponseKeys.Latitude] = placemark.coordinate.latitude as Double
							self.studentInformation[ParseClient.JSONResponseKeys.Longitude] = placemark.coordinate.longitude as Double
		
						}
					}
				}
			}
		} else {
			if shouldCleanTextView == true {
				displayError("Must Enter a Link")
			} else {
				//loadingScreenSetActive(true)
				
				if checkLink(linkTextField.text) {
					// AJEITAR ISSO AQUI DIREITAMENTE
					UdacityClient.sharedInstance().getPublicUserData() { result, error in
						if let dictionary = result {
							self.studentInformation[ParseClient.JSONResponseKeys.FirstName] = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
							self.studentInformation[ParseClient.JSONResponseKeys.LastName] = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
							
							println(self.studentInformation)
							
							ParseClient.sharedInstance().postStudentLocation(self.studentInformation) { success in
								if success {
									self.dismissViewControllerAnimated(true, completion: nil)
								} else {
									self.displayError("Error Posting Location")
								}
							}
						}
					}
				} else {
					displayError("Invalid Link. Include http(s)://")
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
	
	// MARK: - Helper methods
	
	/* Puts the text field in the initial state */
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
	
	/* Configure the UI to present the "location screen" */
	func configureLocationUI() {
		label1.alpha = 1.0
		label2.alpha = 1.0
		label3.alpha = 1.0
		
		linkTextField.alpha = 0.0
		
		map.alpha = 0.0
		
		submitButton.setTitle("Find on the Map", forState: .Normal)
		cancelButton.titleLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.59, alpha: 1.0)
		
		self.view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
		
		resetTextView()
	}
	
	/* Configure the UI to presente the "link screen" */
	func configureLinkUI() {
		label1.alpha = 0.0
		label2.alpha = 0.0
		label3.alpha = 0.0
	
		linkTextField.alpha = 1.0
		
		map.alpha = 1.0
		
		submitButton.setTitle("Submit", forState: .Normal)
		cancelButton.titleLabel?.textColor = UIColor.whiteColor()
		
		self.view.backgroundColor = UIColor(red: 0.29, green: 0.57, blue: 0.75, alpha: 1.0)
		
		resetTextView()
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
	
	func displayError(errorString: String?) {
		dispatch_async(dispatch_get_main_queue()) {
			self.loadingScreenSetActive(false)
			if let errorString = errorString {
				let alertController = UIAlertController(title: "Error", message: "An error has ocurred\n" + errorString, preferredStyle: .Alert)
				let DismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
				alertController.addAction(DismissAction)
				self.presentViewController(alertController, animated: true) {}
			}
		}
	}
	
	func checkLink (urlString: String?) -> Bool {
		if let urlString = urlString {
			if let url = NSURL(string: urlString) {
				return UIApplication.sharedApplication().canOpenURL(url)
			}
		}
		return false
	}
}