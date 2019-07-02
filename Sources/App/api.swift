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
	

	let apiClient: APIProtocol = APIClient()
	let searchAPIClient: SearchAPIProtocol = SearchAPIClient()

	router.get("api/v1/test") { req -> String in
		return "Test"
	}
	
	router.get("api/v1/videos") { req -> Response in
		let videos = apiClient.getVideos(try req.getDb())
		return req.response(try JSONEncoder().encode(videos))
	}
	router.get("api/v1/video", String.parameter) { req -> Response in
		let value = try req.parameters.next(String.self)
		let video = apiClient.getVideo(try req.getDb(), shortUrl: value)
		return req.response(try JSONEncoder().encode(video))
	}
	
	router.get("api/v1/conferences") { req -> Response in
		let conferences = apiClient.getConferences(try req.getDb())
		return req.response(try JSONEncoder().encode(conferences))
	}
	
	router.get("api/v1/conference", String.parameter) { req -> Response in
		let value = try req.parameters.next(String.self)
		let conference = apiClient.getConference(try req.getDb(), shortUrl: value)
		return req.response(try JSONEncoder().encode(conference))
	}
	
	router.get("api/v1/random") { req -> Response in
		let randomVideo = apiClient.getRandomVideo(try req.getDb())
		return req.response(try JSONEncoder().encode(randomVideo))
	}
	
	router.get("api/v1/speakers") { req -> Response in
		let speakers = apiClient.getSpeakers(try req.getDb())
		return req.response(try JSONEncoder().encode(speakers))
	}
	
	router.get("api/v1/speaker", String.parameter) { req -> Response in
		let value = try req.parameters.next(String.self)
		let speaker = apiClient.getSpeaker(try req.getDb(), shortUrl: value)
		return req.response(try JSONEncoder().encode(speaker))
	}

	router.get("api/v1/tag", String.parameter) { req -> Response in
		let value = try req.parameters.next(String.self)
		let tag = apiClient.getTagVideos(try req.getDb(), tag: value)
		return req.response(try JSONEncoder().encode(tag))
	}
	
	router.get("api/v1/events") { req -> Response in
		let events = apiClient.getEvents(try req.getDb())
		return req.response(try JSONEncoder().encode(events))
	}
	
	router.get("api/v1/event", String.parameter) { req -> Response in
		let value = try req.parameters.next(String.self)
		let event = apiClient.getEvent(try req.getDb(), shortUrl: value)
		return req.response(try JSONEncoder().encode(event))
	}
	
	router.get("api/v1/today") { (req: Request) -> Response in
		let video = apiClient.getTodaysVideo(try req.getDb())
		return req.response(try JSONEncoder().encode(video))
	}
	
	router.get("api/v1/search", String.parameter) { req -> Response in
		let db = try req.getDb()
		let searchText = try req.parameters.next(String.self)
		let content = getSearchContext(db, for: searchText)
		return req.response(try JSONEncoder().encode(content))
	}
	
	router.post("api/v1/search") { req -> Response in
		let db = try req.getDb()
		let searchText: String = try req.content.syncGet(at: "searchText")
		searchAPIClient.save(db, searchText: searchText)
		let content = getSearchContext(db, for: searchText)
		return req.response(try JSONEncoder().encode(content))
	}
	
	func getSearchContext(_ db: MongoKitten.Database, for searchText: String) -> EventLoopFuture<SearchContext> {
		return searchAPIClient.getSearchedSpeakers(db, searchText: searchText)
			.and(searchAPIClient.getSearchedConferences(db, searchText: searchText))
			.and(searchAPIClient.getSearchedVideos(db, searchText: searchText))
			.map ({ (result) -> SearchContext in
				var hasResult = true
				if result.0.0.isEmpty && result.0.1.isEmpty && result.1.isEmpty {
					hasResult = false
				}
				
				let context = SearchContext(videos: result.1, conferences: result.0.1, speakers: result.0.0, hasResult: hasResult)
				return context
			})
	}
}

private extension Request {
	func getDb() throws -> MongoKitten.Database {
		return try make(MongoKitten.Database.self)
	}
}
