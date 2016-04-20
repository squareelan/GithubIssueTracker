//
//  GithubRepo.swift
//  SearchMeRepos
//
//  Created by Ian on 4/18/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import ObjectMapper

struct GithubRepo: Mappable {

	// only serialize and deserialize needed fields for now.
	var name: String?

	init?(_ map: Map) {

	}

	mutating func mapping(map: Map) {
		name		<- map["name"]
	}
}
