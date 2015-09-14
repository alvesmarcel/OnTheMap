//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for the Map View. It's the screen that comes after a successful login.
//  Students locations are displayed as pins on the map.
//  When the pin is touched, student information (first name, last name and mediaURL) appears.

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
	
	// MARK: - Outlets

	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Class variables
	
	var annotations = [MKPointAnnotation]()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Setting map delegate */
		mapView.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		
		/* Notification is used to update the mapView when student information is saved */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMapView:", name: "StudentLocationsSavedNotification", object: nil)
		
		/* Ensure mapView is updated when the view appears - this doesn't consume network data */
		updateMapView(self)
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		/* Removing observers */
		NSNotificationCenter.defaultCenter().removeObserver(self)
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
	
	// MARK: - Helper methods
	
	/* Takes the student locations in the shared instance of ParseClient and updates the map */
	func updateMapView(sender: AnyObject?) {
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
}