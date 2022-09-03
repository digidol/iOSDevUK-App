//
//  IDUAppData.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 18/08/2019.
//  Copyright © 2019-2022 Aberystwyth University. All rights reserved.

import Foundation

class IDUAppData {
    
    var dataVersion: Int
    
    var startDate: Date
    
    var endDate: Date
    
    var days = [IDUDay]()
    
    var speakers = [IDUSpeaker]()
    
    init(version: Int, start: Date, end: Date) {
        self.dataVersion = version
        self.startDate = start
        self.endDate = end
    }
    
    func sortedSpeakers() -> [IDUSpeaker] {
        return speakers.sorted(by: { $0.name > $1.name })
    }
}


class IDUDay {
    var recordName: String
    var date: Date
    var sections = [IDUSection]()
    
    init(recordName: String, date: Date) {
        self.recordName = recordName
        self.date = date
    }
    
    deinit {
        //print("de-initialising IDUDay \(recordName)")
        sections.removeAll()
    }
}

class IDUSection {
    var recordName: String
    var name: String
    var sessions = [IDUSession]()
    
    unowned var day: IDUDay
    
    init(recordName: String, name: String, day: IDUDay) {
        self.recordName = name
        self.name = name
        self.day = day
    }
    
    deinit {
        //print("de-initialising IDUSection \(recordName)")
        sessions.removeAll()
    }
}

class IDUSession {
    var recordName: String
    var startTime: Date
    var endTime: Date
    var sessionItems = [IDUSessionItem]()
    
    unowned var section: IDUSection
    
    init(recordName: String, start: Date, end: Date, section: IDUSection) {
        self.recordName = recordName
        self.startTime = start
        self.endTime = end
        self.section = section
    }
    
    deinit {
        //print("de-initialising IDUSession \(recordName)")
        sessionItems.removeAll()
    }
    
//    func sessionItem(atPosition position: Int) -> IDUSessionItem? {
//
//        // filter to remove possible session items where location is nil, before sorting
//        let items = sessionItems.filter( { $0.location != nil } ).sorted(by: {
//            $0.location!.recordName > $1.location!.recordName
//        })
//
//        if position < items.count {
//            return items[position]
//        }
//        return nil
//    }
}

enum IDUSessionItemType: String, Codable {
    case coffeeBiscuits
    case coffeeCake
    case registration
    case train
    case lunch
    case talk
    case workshop
    case social
    case dinner
}

class IDUSessionItem {
    var recordName: String
    var title: String
    var content: String
    var type: IDUSessionItemType?
    
    var listOnFrontScreen = true
    
    var speakers = [IDUSpeaker]()
    var location: IDULocation?
    
    var session: IDUSession
    
    init(recordName: String, title: String, content: String, type: String, session: IDUSession) {
        self.recordName = recordName
        self.title = title
        self.content = content
        
        self.type = IDUSessionItemType(rawValue: type)
        
        self.session = session
    }
    
    deinit {
        //print("de-initialising IDUSessionItem \(recordName)")
        speakers.removeAll()
    }
    
    func speakerNames() -> String {
        return speakers.reduce("", { partial, item in
            var result = partial
            
            if result.count != 0 {
                result += " & "
            }
        
            result += item.name
            return result
        })
    }
    
    func sortedSpeakers() -> [IDUSpeaker] {
        return self.speakers.sorted(by: { $0.name > $1.name } )
    }
    
    func matches(text: String) -> Bool {
        let lowercasedString = text.lowercased()
    
        return title.lowercased().contains(lowercasedString) ||
               content.lowercased().contains(lowercasedString) ||
               speakerNames().lowercased().contains(lowercasedString)
    }
}

class IDUSpeaker {
    
    var recordName: String

    var name: String
    
    var biography: String
    
    var twitterId: String?
    
    var linkedIn: String?
    
    var sessionItems = [IDUSessionItem]()
    
    var webLinks = [IDUWebLink]()
    
    var imageVersion: Int?
    
    init(recordName: String, name: String, biography: String) {
        self.name = name
        self.recordName = recordName
        self.biography = biography
    }
    
    deinit {
        //print("de-initialising IDUSpeaker \(recordName)")
        sessionItems.removeAll()
        webLinks.removeAll()
    }
}

/**
 
 */
class IDUWebLink {
    
    var name: String
    
    var url: URL
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

class IDULocationType {
    var recordName: String
    var name: String
    var order: Int
    
    var locations = [IDULocation]()
    
    init(recordName: String, name: String, order: Int) {
        self.recordName = recordName
        self.name = name
        self.order = order
    }
    
    deinit {
        //print("de-initialising IDULocationType \(recordName)")
        locations.removeAll()
    }
}

class IDULocation {
    var recordName: String
    var name: String
    var shortName: String
    var frontListPosition: Int
    var showImage: Bool
    var latitude: Double
    var longitude: Double
    
    weak var locationType: IDULocationType?
    
    var note: String?
    
    var webLink: IDUWebLink?
    
    var imageVersion: Int?
    
    init(recordName: String, name: String, shortName: String, frontListPosition: Int, showImage: Bool, latitude: Double, longitude: Double) {
        self.recordName = recordName
        self.name = name
        self.shortName = shortName
        self.frontListPosition = frontListPosition
        self.showImage = showImage
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

class IDUUserSettings {
    
}
