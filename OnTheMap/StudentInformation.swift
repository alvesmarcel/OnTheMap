//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/31/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is used to represent the student information used in the Parse API for GET and POST requests
//  Some information (provided by the Parse's response) are not represented in this class because they are not needed

import Foundation

class StudentInformation: NSObject, Printable {

	var objectID: String = ""
	var uniqueKey: String = ""
	var firstName: String = ""
	var lastName: String = ""
	var mapString: String = ""
	var mediaURL: String = ""
	var latitude: Double = 0.0
	var longitude: Double = 0.0
	
	// MARK: - Constructors
	
	/* Construct a StudentInformation object from a dictionary */
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
	
	// MARK: - Helpers
	
	/* Given an array of dictionaries, convert them to an array of StudentInformation objects */
	static func studentLocationsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
		var studentInformation = [StudentInformation]()
		
		for result in results {
			studentInformation.append(StudentInformation(dictionary: result))
		}
		
		return studentInformation
	}
	
	// MARK: - Debug
	
	/* Method used only for debug purposes */
	override  var description: String {
		return "objectID: \(objectID)\nuniqueKey: \(uniqueKey)\nfirstName: \(firstName)\nlastName: \(lastName)\nmapString: \(mapString)\nmediaURL: \(mediaURL)\nlatitude: \(latitude)\nlongitude: \(longitude)"
	}
}