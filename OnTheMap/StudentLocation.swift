//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/31/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import Foundation

class StudentLocation: NSObject, Printable {

	var objectID: String = ""
	var uniqueKey: String = ""
	var firstName: String = ""
	var lastName: String = ""
	var mapString: String = ""
	var mediaURL: String = ""
	var latitude: Double = 0.0
	var longitude: Double = 0.0
	
	override  var description: String {
		return "objectID: \(objectID)\nuniqueKey: \(uniqueKey)\nfirstName: \(firstName)\nlastName: \(lastName)\nmapString: \(mapString)\nmediaURL: \(mediaURL)\nlatitude: \(latitude)\nlongitude: \(longitude)"
	}
	
	init(dictionary: [String : AnyObject]) {
		
		objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
		uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
		firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
		lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
		mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
		mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
		latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
		longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
	}
	
	static func studentLocationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
		var studentLocation = [StudentLocation]()
		
		for result in results {
			studentLocation.append(StudentLocation(dictionary: result))
		}
		
		return studentLocation
	}
}