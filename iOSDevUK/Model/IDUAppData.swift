//
//  IDUAppData.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 18/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

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
        print("de-initialising IDUDay \(recordName)")
        sections.removeAll()
    }
}

class IDUSection {
    var recordName: String
    var name: String
    var sessions = [IDUSession]()
    
    init(recordName: String, name: String) {
        self.recordName = name
        self.name = name
    }
    
    deinit {
        print("de-initialising IDUSection \(recordName)")
        sessions.removeAll()
    }
}

class IDUSession {
    var recordName: String
    var startTime: Date
    var endTime: Date
    var sessionItems = [IDUSessionItem]()
    
    init(recordName: String, start: Date, end: Date) {
        self.recordName = recordName
        self.startTime = start
        self.endTime = end
    }
    
    deinit {
        print("de-initialising IDUSession \(recordName)")
        sessionItems.removeAll()
    }
}

enum IDUSessionItemType: String, Codable {
    case coffeeBiscuits
    case coffeeCake
    case registration
    case train
    case lunch
    case talk
    case workshop
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
        print("de-initialising IDUSessionItem \(recordName)")
        location = nil
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
}

class IDUSpeaker {
    
    var recordName: String

    var name: String
    
    var biography: String
    
    var twitterId: String?
    
    var linkedIn: String?
    
    var sessionItems = [IDUSessionItem]()
    
    var webLinks = [IDUWebLink]()
    
    init(recordName: String, name: String, biography: String) {
        self.name = name
        self.recordName = recordName
        self.biography = biography
    }
    
    deinit {
        print("de-initialising IDUSpeaker \(recordName)")
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
        print("de-initialising IDULocationType \(recordName)")
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
    
    weak var webLink: IDUWebLink?
    
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
    
    deinit {
        print("de-initialising IDULocation \(recordName)")
    }
    
}

class IDUUserSettings {
    
}