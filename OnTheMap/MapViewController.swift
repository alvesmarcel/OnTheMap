//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for the Map View. It's the screen that comes after a successful login.
//  The NavigationBarButtons are initialized here.
//  Students locations are displayed as pins on the map.
//  When the pin is touched, student information (first name, last name and mediaURL) appears.
//  All the UI methods of the TabBarViewController (parentViewController) are treated here.

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
	
	// MARK: - Outlets

	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Class variables
	
	var annotations = [MKPointAnnotation]()
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Passing parentViewController view as reference */
		/* This makes the loading screen works in the list view */
		if let parentView = self.parentViewController?.view {
			loadingScreen = LoadingScreen(view: parentView)
		}
		
		/* Adding the left bar button (logout) to the navigation bar */
		let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout:")
		self.parentViewController!.navigationItem.setLeftBarButtonItem(logoutBarButtonItem, animated: true)
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "pinBarButtonTouch:")
		self.parentViewController!.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
		
		/* Setting map delegate */
		mapView.delegate = self
		
		/* When the view is loaded, the locations are fetched from the server and the view updated */
		refreshLocations(self)
	}
	
	// MARK: - Actions
	
	/* Realizes the logout and dismiss the view */
	func logout(sender: AnyObject) {
		// TODO: Implement Logout
		self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
	}
	
	/* pinBarButtonItem action - Verifies if the student has already posted the information */
	/* Then calls callInformationPostViewControllerWithDictionary:toUpdate: with the correct parameters */
	func pinBarButtonTouch(sender: AnyObject) {
		loadingScreen.setActive(true)
		UdacityClient.sharedInstance().getPublicUserData() { result, error in
			
			if error != nil {
				ErrorDisplay.displayErrorWithTitle("Error Getting Student Information", errorDescription: "Could Not Get Student Information from Server", inViewController: self.parentViewController!, andDeactivatesLoadingScreen: self.loadingScreen)
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
				ErrorDisplay.displayErrorWithTitle("Could Not Get Locations", errorDescription: error.localizedDescription, inViewController: self.parentViewController!, andDeactivatesLoadingScreen: self.loadingScreen)
			} else {
				self.loadingScreen.setActive(false)
				self.updateMapView()
				NSNotificationCenter.defaultCenter().postNotificationName("StudentLocationsSavedNotification", object: nil)
				println("Students Locations saved")
			}
		}
	}
	
	// MARK: - MKMapViewDelegate methods
	
	/* Configures how the pins will me shown for each annotation */
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinColor = .Red
			pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	/* Configures the response for touching the annotation view */
	/* In this app, it will open the URL that is the subtitle of the annotation */
	func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == annotationView.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
		}
	}
	
	// MARK: - MapViewController
	
	/* Takes the student locations in the shared instance of ParseClient and updates the map */
	func updateMapView() {
		dispatch_async(dispatch_get_main_queue()) {
			
			/* Cleaning old annotations (so they don't overlap every time the app updates */
			self.mapView.removeAnnotations(self.annotations)
			self.annotations.removeAll(keepCapacity: false)
			
			/* Students information are used to create the annotations that are appended to the class variable annotations */
			for studentLocation in ParseClient.sharedInstance().studentsInformation {
				let latitude = CLLocationDegrees(studentLocation.latitude)
				let longitude = CLLocationDegrees(studentLocation.longitude)
				
				let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				
				let firstName = studentLocation.firstName
				let lastName = studentLocation.lastName
				let mediaURL = studentLocation.mediaURL
				
				var annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				annotation.title = "\(firstName) \(lastName)"
				annotation.subtitle = mediaURL
				
				self.annotations.append(annotation)
			}
			
			/* Adding annotations to the mapView */
			self.mapView.addAnnotations(self.annotations)
		}
	}
	
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
			self.parentViewController!.presentViewController(controller, animated: true, completion: nil)
		}
	}
}