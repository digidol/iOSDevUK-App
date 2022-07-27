//
//  AppData.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 12/08/2019.
//  Copyright © 2019-2022 Aberystwyth University. All rights reserved.

import Foundation

/**
   Holds information about the current versions of the data types that can be accessed from the server.
 
   This is used to offer a small optimisation of not transferring other data across the network if the local data
   is already up to date.
 */
struct ServerMetadata: Codable, CustomStringConvertible {
    
    /** Version number for the schedule information. */
    var dataVersion: Int
    
    /** Version number of the locations data. */
    var locationsVersion: Int
    
    init() {
        dataVersion = 0
        locationsVersion = 0
    }
    
    var description: String {
        return "ServerMetadata data: \(dataVersion) locations: \(locationsVersion)"
    }
}

class ServerLocationsData: Codable, CustomStringConvertible {
    
    var dataVersion: Int
    
    /** List of location types. */
    var locationTypes: [ServerLocationType]
    
    /** List of locations. */
    var locations: [ServerLocation]
    
    /** List of web links. */
    var webLinks: [ServerWebLink]
    
    var description: String {
        return "ServerLocationsData counts for location types: \(locationTypes.count), locations: \(locations.count), web links: \(webLinks.count)"
    }
}

class CombinedServerAppData {
    
    var schedule: ServerAppData?
    
    var locations: ServerLocationsData?
    
}

/**
  The collection of data that is avaialble in a JSON file on the server. It includes information about the schedule as well
   as details about speakers, locations, types of location, sponsors, and the web links that are shown in the app.
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
    
    /** List of web links. */
    var webLinks: [ServerWebLink]
    
    var description: String {
        return "ServerAppData counts for days: \(days.count), speakers: \(speakers.count), web links: \(webLinks.count)"
    }    
}

class ServerDay: Codable, CustomStringConvertible {
    
    /** Using format "dX", where X is the day number, starting at 1. For example, first day of the conference would be "d1" */
    var recordName: String
    
    /** ISO formatted date, e.g. 2022-09-06T10:10:00Z */
    var date: Date
    
    /** List of sections, where a section represents part of a day such as Monday am */
    var sections: [ServerSection]
    
    var description: String {
        return "ServerDay: recordName: \(recordName), date: \(date), number of sections: \(sections.count)"
    }
}

/**
  A section is part of a day. These are used to provide blocks of sessions. Example sections are "Monday am" and "Monday pm".
 */
class ServerSection: Codable {
    
    /**
     The identifiier for the record, which follows the format of "dX_sY", where X is the day number (starting at 1) and
      Y is the section number in the day, starting at 1.  For example, the first section of the first day would be 'd1_s1" and
        the second section of the second day would be "d2_s2".
     */
    var recordName: String
    
    /** The name that will be displayed for the section, e.g. "Monday am" */
    var name: String
    
    /** As many sessions as needed for this block of sessions. */
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

/**
  Represents a speaker for the conference.
 */
class ServerSpeaker: Codable {
    
    /** This is an identifier, e.g. NeilTaylor. This will be used to access any image updates on the server. */
    var recordName: String
    
    /** The display name for the speaker. */
    var name: String
    
    /** The Twitter ID, e.g. digidol, if provided by the speaker. */
    var twitterId: String?
    
    /** A URL for LinkedIn, if provided by the speaker. */
    var linkedIn: String?
    
    /** Speaker's biography, which includes \n\n characters to provide paragraph breaks. */
    var biography: String
    
    /** List of any web links provided by the speaker. */
    var webLinkRecordNames: [String]?
    
    /** Version number for the image of the speaker. */
    var imageVersion: Int?
    
    // The following items are expected to be populated once
    // the data has been loaded into memory
    private var speakerSessionItems: [ServerSessionItem]?
    
    private var speakerWebLinks: [ServerWebLink]?
         
    /*func sessionItems() -> [ServerSessionItem]? {
        return []
    }
    
    func webLinks() -> [ServerWebLink]? {
        return []
    }*/
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
