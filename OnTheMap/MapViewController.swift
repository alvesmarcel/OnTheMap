//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var loadingScreenView: UIView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	var annotations = [MKPointAnnotation]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		activityIndicatorView.hidesWhenStopped = true
		
		
		refreshLocations(self)
		
//		
//		// The "locations" array is an array of dictionary objects that are similar to the JSON
//		// data that you can download from parse.
//		let locations = hardCodedLocationData()
//		
//		// We will create an MKPointAnnotation for each dictionary in "locations". The
//		// point annotations will be stored in this array, and then provided to the map view.
//		var annotations = [MKPointAnnotation]()
//		
//		// The "locations" array is loaded with the sample data below. We are using the dictionaries
//		// to create map annotations. This would be more stylish if the dictionaries were being
//		// used to create custom structs. Perhaps StudentLocation structs.
//		
//		for dictionary in locations {
//			
//			// Notice that the float values are being used to create CLLocationDegree values.
//			// This is a version of the Double type.
//			let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
//			let long = CLLocationDegrees(dictionary["longitude"] as! Double)
//			
//			// The lat and long are used to create a CLLocationCoordinates2D instance.
//			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//			
//			let first = dictionary["firstName"] as! String
//			let last = dictionary["lastName"] as! String
//			let mediaURL = dictionary["mediaURL"] as! String
//			
//			// Here we create the annotation and set its coordiate, title, and subtitle properties
//			var annotation = MKPointAnnotation()
//			annotation.coordinate = coordinate
//			annotation.title = "\(first) \(last)"
//			annotation.subtitle = mediaURL
//			
//			// Finally we place the annotation in an array of annotations.
//			annotations.append(annotation)
//		}
//		
//		// When the array is complete, we add the annotations to the map.
//		self.mapView.addAnnotations(annotations)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		/* Adding the right bar buttons to the navigation bar */
		let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshLocations:")
		let pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "callInformationPostViewController:")
		self.tabBarController!.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: true)
	}
	
	func refreshLocations(sender: AnyObject?) {
		initLoadScreen()
		ParseClient.sharedInstance().getStudentsLocations(100, skip: 0) { studentLocations, error in
			if let error = error {
				self.displayError(error.localizedDescription)
			} else {
				if let locations = studentLocations {
					//self.studentLocations = locations
					dispatch_async(dispatch_get_main_queue()) {
						self.updateMapView()
						self.dismissLoadScreen()
					}
					println("Students Locations saved")
				} else {
					println("Unexpected Error")
				}
			}
		}
	}
	
	func initLoadScreen() {
		self.activityIndicatorView.startAnimating()
		self.loadingScreenView.hidden = false
	}
	
	func dismissLoadScreen() {
		self.activityIndicatorView.stopAnimating()
		self.loadingScreenView.hidden = true
	}
	
	func updateMapView() {
		mapView.removeAnnotations(annotations)
		annotations.removeAll(keepCapacity: false)
		
		for studentLocation in ParseClient.sharedInstance().studentLocations {
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
			
			annotations.append(annotation)
		}

		self.mapView.addAnnotations(annotations)
	}
	
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

	
	
	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

		if control == annotationView.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
		}
	}
	
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
}