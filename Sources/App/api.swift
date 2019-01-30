//
//  api.swift
//  App
//
//  Created by Serhii Londar on 1/30/19.
//
import Vapor
import MongoKitten
import Paginator

/// Register your api routes here.
public func apiRoutes(_ router: Router) throws {
	
	let databaseUrl = Environment.get("DB_URL")
	let apiClient: APIProtocol = APIClient(databaseUrl: databaseUrl)
	let searchAPIClient: SearchAPIProtocol = SearchAPIClient(databaseUrl: databaseUrl)

	router.get("test") { req -> String in
		return "Test"
	}
	
	router.get("api/v1/speakers") { req -> Response in
		guard let speakers = apiClient.getSpeakers() else {
			return req.response("{\"error\" : \"Error while getting speakers.\"}")
		}
		let data = try JSONEncoder().encode(speakers)
		return req.response(data)
	}
	
	router.get("api/v1/videos") { (req: Request) -> Response in
		guard let videos = apiClient.getVideos() else {
			return req.response("{\"error\" : \"Error while getting videos.\"}")
		}
		let data = try JSONEncoder().encode(videos)
		return req.response(data)
	}
}
