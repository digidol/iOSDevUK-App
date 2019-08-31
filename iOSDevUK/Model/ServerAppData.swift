//
//  AppData.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 12/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation

class ServerMetadata: Codable {
    var dataVersion: Int
}

/**
 
 */
class ServerAppData: Codable, CustomStringConvertible {
    
    /** Version of the data file, e.g. 2019001. Larger numbers represent more recent versions. */
    var dataVersion: Int
    
    /** Start date and time for the current conference. */
    var startDate: Date
    
    /** End date and time for the current conference. */
    var endDate: Date
    
    /** List of days, which contains information and sections (am/pm/evening), sessions (a time) and session items (talks, workshops, etc.). */
    var days: [ServerDay]
    
    /** List of speakers. */
    var speakers: [ServerSpeaker]
    
    /** List of location types. */
    var locationTypes: [ServerLocationType]
    
    /** List of locations. */
    var locations: [ServerLocation]
    
    /** List of web links. */
    var webLinks: [ServerWebLink]
    
    var sponsors: [ServerSponsor]
    
    var description: String {
        return "ServerAppData counts for days: \(days.count), speakers: \(speakers.count), location types: \(locationTypes.count), locations: \(locations.count), web links: \(webLinks.count) sponsors: \(sponsors.count)"
    }    
}





class ServerDay: Codable, CustomStringConvertible {
    
    var recordName: String
    
    var date: Date
    
    var sections: [ServerSection]
    
    var description: String {
        return "ServerDay: recordName: \(recordName), date: \(date), number of sections: \(sections.count)"
    }
}

class ServerSection: Codable {
    
    var recordName: String
    
    var name: String
    
    var sessions: [ServerSession]
}

class ServerSession: Codable {
    
    var recordName: String
    
    var startTime: Date
    
    var endTime: Date
    
    var sessionItems: [ServerSessionItem]
    
}

class ServerSessionItem: Codable {
    
    var recordName: String
    
    var title: String
    
    var content: String
    
    var type: String
    
    var listOnFrontScreen: Bool?
    
    var speakerRecordNames: [String]
    
    var locationRecordName: String
    
}


class ServerSpeaker: Codable {
    var recordName: String
    var name: String
    var twitterId: String?
    var linkedIn: String?
    var biography: String
    var webLinkRecordNames: [String]?
    var imageVersion: Int?
    
    // The following items are expected to be populated once
    // the data has been loaded into memory
    private var speakerSessionItems: [ServerSessionItem]?
    
    private var speakerWebLinks: [ServerWebLink]?
         
    func sessionItems() -> [ServerSessionItem]? {
        return []
    }
    
    func webLinks() -> [ServerWebLink]? {
        return []
    }
}

class ServerLocationType: Codable {
    var recordName: String
    var name: String
    var order: Int
}

class ServerLocation: Codable {
    var recordName: String
    var name: String
    var shortName: String
    var frontListPosition: Int
    var showImage: Bool
    var latitude: Double
    var longitude: Double
    var locationTypeRecordName: String
    var note: String?
    var webLinkRecordName: String?
    var imageVersion: Int?
}

class ServerWebLink: Codable {
    var recordName: String
    var url: URL
    var name: String
}

enum SponsorCellType: String, Codable {
    case imageTop
    case imageRight
}

enum SponsorCategory: String, Codable {
    case Platinum
    case Gold
    case Silver
}

class ServerSponsor: Codable {
    var recordName: String
    var name: String
    var tagline: String
    var sponsorOrder: Int
    var url: URL?
    var urlText: String?
    var sponsorCategory: SponsorCategory
    var cellType: SponsorCellType
    var note: String
    var imageVersion: Int
}
