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
		
		loadingScreen = LoadingScreen(view: self.view)
		
		/* Setting map delegate */
		mapView.delegate = self
		
		/* When the view is loaded, the locations are fetched from the server and the view updated */
		refreshLocations(self)
		
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "callInformationPostViewController:")
		self.tabBarController!.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
	
	// MARK: - Actions
	
	/* Calls the InformationPostViewController modally - pinBarButtonItem action */
	func callInformationPostViewController(sender: AnyObject) {
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostViewController") as! InformationPostViewController
		self.presentViewController(controller, animated: true, completion: nil)
	}
	
	/* Fetchs locations from the server and updates the mapView - refreshBarButtonItem action */
	func refreshLocations(sender: AnyObject?) {
		loadingScreen.setActive(true)
		ParseClient.sharedInstance().getStudentsLocationsWithLimit(100, skip: 0) { studentLocations, error in
			if let error = error {
				self.displayError(error.localizedDescription)
			} else {
				
				// TODO: Pass locations to updateMapView by reference
				if let locations = studentLocations {
					self.loadingScreen.setActive(false)
					self.updateMapView()
					println("Students Locations saved")
				} else {
					println("Unexpected Error")
				}
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
			
			/* Cleaning old annotations (so they don't overlap every time we update */
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
	
	// MARK: - UI Helper Methods
	
	/* Displays error using alert controller */
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
	
	/* Activates (or deactivates) the loading screen */
//	func loadingScreenSetActive(active: Bool) {
//		dispatch_async(dispatch_get_main_queue()) {
//			// TODO: IMPLEMENT
//			// create activity indicator view
//			// - activity view should hide when stop
//			// change alpha of screen to 0.5
//			// - screen shouldn't be editable
//		}
//	}
}