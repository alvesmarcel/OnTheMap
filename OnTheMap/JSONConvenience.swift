//
//  Convenience.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/31/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class contains some methods to help with JSON data that is returned in the API calls
//  All methods were taken from Udacity The Movie Manager app (Created by Jarrod Parkes on 2/11/15)

import Foundation

class JSONConvenience {
	
	/* Given raw JSON data, return a usable Foundation object */
	class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		
		var parsingError: NSError? = nil
		
		let parsedResult: AnyObject?
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
		} catch let error as NSError {
			parsingError = error
			parsedResult = nil
		}
		
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			completionHandler(result: parsedResult, error: nil)
		}
	}
	
	/* Given a dictionary of parameters, return a string that will compose the URL  */
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		
		var urlVars = [String]()
		
		for (key, value) in parameters {
			
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
			
		}
		
		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
	}
}