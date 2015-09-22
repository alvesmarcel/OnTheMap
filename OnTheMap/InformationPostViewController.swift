//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for posting student information in the servers using the Parse methods
//  There are "two" implicit screens in this view (Location UI and Link UI). They change between them with alpha configurations.

import UIKit
import MapKit

class InformationPostViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {

	// MARK: - UIButtons
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var previewLinkButton: UIButton!
	
	// MARK: - UILabels
	
	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var label3: UILabel!
	
	// MARK: - UITextViews
	
	@IBOutlet weak var locationTextView: UITextView!
	@IBOutlet weak var linkTextView: UITextView!
	
	// MARK: - MKMapView
	
	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Class variables
	
	var shouldCleanTextView: Bool!
	var loadingScreen: LoadingScreen!
	var studentInformation = StudentInformation()
	var objectID: String?
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Setting the delegates */
		locationTextView.delegate = self
		linkTextView.delegate = self
		
		/* Setting mapView configurations */
		mapView.zoomEnabled = false
		mapView.scrollEnabled = false
		mapView.delegate = self
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
		
		/* When the view is loaded, the LocationUI must appear */
		configureLocationUI()
	}
	
	// MARK: - Actions
	
	@IBAction func cancelButtonTouch(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	/* Deals with "Find on the Map" (if) or "Submit" (else) button (they are the same) touch */
	@IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
		
		locationTextView.resignFirstResponder()
		linkTextView.resignFirstResponder()

		/* When button's text is "Find on the Map", the button is dealing with the "first" screen (Location UI) */
		if submitButton.titleLabel?.text == "Find on the Map" {
			
			/* The text view is clean or should be cleaned - so, it should not proceed */
			if shouldCleanTextView == true {
				ErrorDisplay.displayErrorWithTitle("Missing Location", errorDescription: "Must Enter Location", inViewController: self, andDeactivatesLoadingScreen: nil)
			} else {
				
				/* The app will try to post the location and activates the loading screen */
				loadingScreen.setActive(true)
				
				/* The geocoder tries to find a location that was in locationTextView */
				let geocoder = CLGeocoder()
				geocoder.geocodeAddressString(locationTextView.text) { placemarks, error in
					
					/* Geocoder could not find the location */
					if let error = error {
	
						ErrorDisplay.displayErrorWithTitle("CLGeocoder Error", errorDescription: "Could not geocode location", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
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
							self.studentInformation.mapString = self.locationTextView.text
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
				
				if checkLink(linkTextView.text) {
					
					/* The link is valid - set loadingScreen active and try to post link with location */
					loadingScreen.setActive(true)
							
					/* Completing student information to be posted */
					self.studentInformation.mediaURL = self.linkTextView.text
					
					if let objectID = self.objectID {
						
						/* objectID is not nil - should PUT (update) student location information */
						studentInformation.objectID = objectID
						ParseClient.sharedInstance().updateStudentLocationWithInformation(self.studentInformation) { success in
							if success {
								
								/* Student information was successfully updated - update MapViewController */
								
								self.loadingScreen.setActive(false)
								self.dismissViewControllerAnimated(true, completion: nil)
								dispatch_async(dispatch_get_main_queue()) {
									NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.ShouldUpdateDataNotification, object: nil)
								}
							} else {
								ErrorDisplay.displayErrorWithTitle("Error Posting Location", errorDescription: "Could Not Post Student Location", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
							}
						}
					} else {
						
						/* objectID is nil - should POST student location information */
						ParseClient.sharedInstance().postStudentLocationWithInformation(self.studentInformation) { success in
							if success {
								
								/* Student information was successfully posted - update MapViewController */
								self.loadingScreen.setActive(false)
								self.dismissViewControllerAnimated(true, completion: nil)
								dispatch_async(dispatch_get_main_queue()) {
									NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.ShouldUpdateDataNotification, object: nil)
								}
							} else {
								ErrorDisplay.displayErrorWithTitle("Error Posting Location", errorDescription: "Could Not Post Student Location", inViewController: self, andDeactivatesLoadingScreen: self.loadingScreen)
							}
						}
					}
					
				} else {
					ErrorDisplay.displayErrorWithTitle("Invalid Link", errorDescription: "Invalid Link. Include http(s)://", inViewController: self, andDeactivatesLoadingScreen: nil)
				}
			}
		}
	}
	
	/* Calls PreviewLinkViewController to show the preview of the web page when the previewLinkButton is touched */
	@IBAction func previewLinkButtonTouch(sender: AnyObject) {
		let previewLinkViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PreviewLinkViewController") as! PreviewLinkViewController
		
		let url = NSURL(string: linkTextView.text)
		let request = NSURLRequest(URL: url!)
		previewLinkViewController.urlRequest = request
		
		let previewLinkNavigationController = UINavigationController()
		previewLinkNavigationController.pushViewController(previewLinkViewController, animated: false)
		
		dispatch_async(dispatch_get_main_queue()) {
			self.presentViewController(previewLinkNavigationController, animated: true, completion: nil)
		}
	}
	
	// MARK: - UITextViewDelegate Methods
	
	/* Cleans text view when needed */
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
				resetTextView(textView)
			} else {
				
				/* Checks if it is in the Link Text View */
				if textView == self.linkTextView {
					if checkLink(self.linkTextView.text) {
						previewLinkButton.setTitle("Tap to preview link", forState: .Normal)
						previewLinkButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
						previewLinkButton.enabled = true
					} else {
						previewLinkButton.setTitle("Invalid Link", forState: .Normal)
						previewLinkButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), forState: .Normal)
						previewLinkButton.enabled = false
					}
				}
			}
			
			return false
		}
		return true
	}
	
	// MARK: - UI Helper methods
	
	/* Puts the text view in the initial state according to the text view alpha */
	/* The alpha condition is essential to avoid updating both text views (correct values are needed to post student location) */
	func resetTextView(textView: UITextView) {
		dispatch_async(dispatch_get_main_queue()) {
			
			/* Identifies which text view is being edited */
			if textView == self.linkTextView {
				self.linkTextView.text = "Enter a Link to Share Here"
				self.previewLinkButton.setTitle("", forState: .Normal)
				self.previewLinkButton.enabled = false
			} else {
				self.locationTextView.text = "Enter Your Location Here"
			}
		}
		shouldCleanTextView = true
	}
	
	/* Configures the UI to present the "location screen" */
	func configureLocationUI() {
		dispatch_async(dispatch_get_main_queue()) {
			self.previewLinkButton.setTitle("", forState: .Normal)
			self.previewLinkButton.enabled = false
			
			self.label1.alpha = 1.0
			self.label2.alpha = 1.0
			self.label3.alpha = 1.0
			
			self.linkTextView.alpha = 0.0
			
			self.mapView.alpha = 0.0
			
			self.submitButton.setTitle("Find on the Map", forState: .Normal)
			self.cancelButton.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.59, alpha: 1.0), forState: .Normal)
			
			self.view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
		}
		resetTextView(self.locationTextView)
	}
	
	/* Configures the UI to presente the "link screen" */
	func configureLinkUI() {
		dispatch_async(dispatch_get_main_queue()) {
			self.previewLinkButton.setTitle("", forState: .Normal)
			self.previewLinkButton.enabled = false
			
			self.label1.alpha = 0.0
			self.label2.alpha = 0.0
			self.label3.alpha = 0.0
			
			self.linkTextView.alpha = 1.0
			
			self.mapView.alpha = 1.0
			
			self.submitButton.setTitle("Submit", forState: .Normal)
			self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
			
			self.view.backgroundColor = UIColor(red: 0.29, green: 0.57, blue: 0.75, alpha: 1.0)
		}
		resetTextView(self.linkTextView)
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