//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 9/2/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Extension of class ParseClient
//  The convenient methods (specific GET and POST methods provided by the Parse API) are here

import Foundation
import UIKit

extension ParseClient {
	
	// MARK: GET Convenient Methods
	
	/* This method is used to consult the student locations */
	/* Given a limit and a skip arguments, this method returns (through completionHandler) an array of student locations or an error */
	func getStudentsLocationsWithLimit(limit: Int, skip: Int, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
		
		/* 1. Specify parameters, method and HTTP body (if POST) */
		let parameters = [
			ParameterKeys.Limit : limit,
			ParameterKeys.Skip : skip
		]
		
		/* 2. Make the request */
		taskForGETMethod(Methods.StudentLocation, parameters: parameters) { JSONResult, error in
			
			/* 3. Send the desired value(s) to completion handler */
			if let error = error {
				completionHandler(result: nil, error: error)
			} else {
				if let results = JSONResult.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
					self.studentsInformation = StudentInformation.studentLocationsFromResults(results)
					completionHandler(result: self.studentsInformation, error: nil)
				} else {
					completionHandler(result: nil, error: NSError(domain: "getStudentsLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentsLocations"]))
				}
			}
		}
	}
	
	// MARK: POST Convenient Methods
	
	/* This method is used to post a student location in the server */
	/* Given a student location, this method returns (through completionHandler) if the post operation was successful or not */
	func postStudentLocationWithInformation(studentInformation: StudentInformation, completionHandler: (success: Bool) -> Void) {
		
		/* 1. Specify parameters, method and HTTP body (if POST) */
		let parameters = [String:AnyObject]()
		let jsonBody: [String:AnyObject] = [
			JSONBodyKeys.UniqueKey	: studentInformation.uniqueKey,
			JSONBodyKeys.FirstName	: studentInformation.firstName,
			JSONBodyKeys.LastName	: studentInformation.lastName,
			JSONBodyKeys.MapString	: studentInformation.mapString,
			JSONBodyKeys.MediaURL	: studentInformation.mediaURL,
			JSONBodyKeys.Latitude	: studentInformation.latitude,
			JSONBodyKeys.Longitude	: studentInformation.longitude
		]
		
		/* 2. Make the request */
		taskForPOSTMethod(Methods.StudentLocation, parameters: parameters, jsonBody: jsonBody) { result, error in
			
			/* 3. Send the desired value(s) to completion handler */
			if let error = error {
				completionHandler(success: false)
			} else {
				completionHandler(success: true)
			}
		}
	}
}