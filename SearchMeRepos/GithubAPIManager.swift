//
//  GithubAPIManager.swift
//  SearchMeRepos
//
//  Created by Ian on 4/18/16.
//  Copyright © 2016 Yongjun Yoo. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import OAuthSwift
import Locksmith

enum Result<T> {
	case Success(T)
	case Error(String, Int)
}

enum ErrorCase: Int {
	case InvalidToken = 9999
	case InvalidRequest = 7777
	case NoResponse = 1234
	case DefaultError = 9998
	case NoResults = -6004 // ObjectMapper failed to serialize error (used as no results came back error)
}

struct GithubErrorDomain {
	static let GithubAPIErrorDomain = "GithubAPIErrorDomain"
}

struct Constants {
	static let AcceptHeader = "application/vnd.github.v3+json"
	static let clientId = "c509725ea894eb4df2ef"
	static let clientSecret = "24eeb4719fc6b89349c9ea51e9bd74ea9f92a6b7"
	static let authorizeUrl = "https://github.com/login/oauth/authorize"
	static let accessTokenUrl = "https://github.com/login/oauth/access_token"
	static let callbackUrl = "gitissues://com.squareelan.gitissues"
	static let userAccount = "github"
	static let tokenKey = "token"
	static let state = "github_oauth2_authenticate"
}

typealias GithubOAuthRequestHandler = ((Bool, NSError?) -> ())

class GithubAPIManager: NSObject {

	// singleton object
	static let sharedInstance = GithubAPIManager()

	private var OAuthCallbackHandler: GithubOAuthRequestHandler?
	private var OAuthToken: String? {
		get {
			let dictionary = Locksmith.loadDataForUserAccount(Constants.userAccount)
			if let token = dictionary?[Constants.tokenKey] as? String {
				return token
			} else {
				return nil
			}
		}

		set {
			if let value = newValue {
				// store the token in keychain
				do {
					try Locksmith.updateData([Constants.tokenKey: value], forUserAccount: Constants.userAccount)
				} catch {
					// not specifically handling the error case
					print("Error: Github OAuth token failed to update")
				}
				// add the Authorization header
				addHeader("Authorization", value: "token \(newValue)")
			} else {
				// delete the token from keychain
				do {
					try Locksmith.deleteDataForUserAccount(Constants.userAccount)
				} catch {
					// not specifically handling the error case
					print("Error: Github OAuth token failed to delete")
				}
				// remove the Authorization header
				removeHeader("Authorization")
			}
		}
	}

	var hasOAuthToken: Bool {
		get {
			if OAuthToken != nil {
				return true
			}
			return false
		}
	}

	override init() {
		super.init()
		addHeader("Accept", value: Constants.AcceptHeader)
	}

	private func addHeader(key: String, value: String) {
		let manager = Alamofire.Manager.sharedInstance
		if var headers = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String> {
			// if there is existing headers, update it
			headers[key] = value
			manager.session.configuration.HTTPAdditionalHeaders = headers
		} else {
			// or create new headers..
			manager.session.configuration.HTTPAdditionalHeaders = [key: value]
		}
	}

	private func removeHeader(key: String) {
		let manager = Alamofire.Manager.sharedInstance
		if var headers = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String> {
			headers.removeValueForKey(key)
			manager.session.configuration.HTTPAdditionalHeaders = headers
		}
	}


	// MARK: - Requests

	func doOAuthLogin(scope: String, callback: GithubOAuthRequestHandler) {
		let oauthswift = OAuth2Swift(consumerKey: Constants.clientId, consumerSecret: Constants.clientSecret, authorizeUrl: Constants.authorizeUrl, accessTokenUrl: Constants.accessTokenUrl, responseType: Constants.tokenKey)

		guard let callbackUrl = NSURL(string: Constants.callbackUrl) else {
			print("OAuth Error: Invalid callback url is provided")
			callback(false, NSError(domain: GithubErrorDomain.GithubAPIErrorDomain, code: ErrorCase.InvalidRequest.rawValue, userInfo: nil))
			return
		}

		oauthswift.authorizeWithCallbackURL(callbackUrl, scope: scope, state: Constants.state, success: { (credential, response, parameters) in
				print("Github token: \(credential.oauth_token)")
				self.OAuthToken = credential.oauth_token
				callback(true, nil)
			}) { (error) in
				print(error.localizedDescription)
				callback(false, error)
		}
	}


	func fetchUserRepos(userName: String, callback: Result<[GithubRepo]> -> ()) {
		guard OAuthToken != nil else {
			callback(.Error("Missing or invalid Authorization Token", ErrorCase.InvalidToken.rawValue))
			return
		}

		let urlEncodedUsername = userName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) ?? ""
		let url = "https://api.github.com/users/\(urlEncodedUsername)/repos"

		Alamofire.request(.GET, url, parameters: nil, encoding: .URL).responseArray { (response: Response<[GithubRepo], NSError>) in
			// Only handling few error cases for this example...
			guard response.result.isSuccess else {
				if let error = response.result.error {
					if error.code == ErrorCase.NoResults.rawValue {
						callback(.Error("No results", error.code))
					} else {
						callback(.Error(error.localizedDescription, error.code))
					}
				} else {
					callback(.Error("Failed to fetch repositories for \(userName)", ErrorCase.DefaultError.rawValue))
				}
				return
			}

			guard let value = response.result.value else {
				callback(.Error("No response is found", ErrorCase.NoResponse.rawValue))
				return
			}

			print(response.result.value)
			callback(.Success(value))
		}
	}

	func fetchIssues(userName: String, repositoryName: String, callback: Result<[GithubIssue]> -> ()) {
		guard OAuthToken != nil else {
			callback(.Error("Missing or invalid Authorization Token", ErrorCase.InvalidToken.rawValue))
			return
		}

		let urlEncodedUsername = userName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) ?? ""
		let urlEncodedRepositoryName = repositoryName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) ?? ""
		let url = "https://api.github.com/repos/\(urlEncodedUsername)/\(urlEncodedRepositoryName)/issues"

		Alamofire.request(.GET, url, parameters: nil, encoding: .URL).responseArray { (response: Response<[GithubIssue], NSError>) in
			// Only handling few error cases for this example...
			guard response.result.isSuccess else {
				if let error = response.result.error {
					if error.code == ErrorCase.NoResults.rawValue {
						callback(.Error("No results", error.code))
					} else {
						callback(.Error(error.localizedDescription, error.code))
					}
				} else {
					callback(.Error("Failed to fetch repositories for \(userName)", ErrorCase.DefaultError.rawValue))
				}
				return
			}

			guard let value = response.result.value else {
				callback(.Error("No response is found", ErrorCase.NoResponse.rawValue))
				return
			}

			print(response.result.value)
			callback(.Success(value))
		}
	}
}
