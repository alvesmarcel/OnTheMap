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

struct StudentInformation {

	var objectID: String = ""
	var uniqueKey: String = ""
	var firstName: String = ""
	var lastName: String = ""
	var mapString: String = ""
	var mediaURL: String = ""
	var latitude: Double = 0.0
	var longitude: Double = 0.0
	
	// MARK: - Constructors
	
	/* Constructs a StudentInformation object with no information */
	init() {}
	
	/* Constructs a StudentInformation object from a dictionary */
	init(dictionary: [String : AnyObject]) {
		
		objectID = dictionary[ParseClient.JSONBodyKeys.ObjectID] as! String
		uniqueKey = dictionary[ParseClient.JSONBodyKeys.UniqueKey] as! String
		firstName = dictionary[ParseClient.JSONBodyKeys.FirstName] as! String
		lastName = dictionary[ParseClient.JSONBodyKeys.LastName] as! String
		mapString = dictionary[ParseClient.JSONBodyKeys.MapString] as! String
		mediaURL = dictionary[ParseClient.JSONBodyKeys.MediaURL] as! String
		latitude = dictionary[ParseClient.JSONBodyKeys.Latitude] as! Double
		longitude = dictionary[ParseClient.JSONBodyKeys.Longitude] as! Double
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
}