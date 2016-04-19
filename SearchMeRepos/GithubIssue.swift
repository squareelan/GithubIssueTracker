//
//  GithubIssue.swift
//  SearchMeRepos
//
//  Created by Ian on 4/19/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import ObjectMapper

struct GithubIssue: Mappable {
	
	// only serialize and deserialize needed fields for now.
	var title: String?
	
	init?(_ map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		title		<- map["title"]
	}
}
