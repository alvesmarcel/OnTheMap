//
//  OTMUser.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import Foundation

class OTMUser : NSObject {
	
	
	
	
	
	
	
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> OTMUser {
		
		struct Singleton {
			static var sharedInstance = OTMUser()
		}
		
		return Singleton.sharedInstance
	}
}