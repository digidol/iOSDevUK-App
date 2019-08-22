//
//  IDUAppDataInitialiser.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 18/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation

class IDUAppDataWrapper {

    private var serverData: ServerAppData
    
    var dayList = [IDUDay]()
    
    var sessionItemList = [IDUSessionItem]()
    
    var speakerList = [IDUSpeaker]()
    
    var locationList = [IDULocation]()
    
    init(serverData: ServerAppData) {
        self.serverData = serverData
        let webLinks = webLinkDictionary()
        
        self.speakerList = speakerList(addingLinks: webLinks)
        
        self.locationList = processLocations(locationTypes: locationTypeList, links: webLinks)
        
        self.dayList = processDays(withSpeakers: speakerDictionary, withLocations: locationDictionary())
        
        self.sessionItemList = sessionItems()

    }
    
    func processDays(withSpeakers speakers: [String:IDUSpeaker], withLocations locations: [String:IDULocation]) -> [IDUDay] {
        var days = [IDUDay]()
        
        serverData.days.forEach { serverDay in
            let day = IDUDay(recordName: serverDay.recordName, date: serverDay.date)
            day.sections = process(sections: serverDay.sections, inDay: day, speakers: speakers, locations: locations)
            days.append(day)
        }
        
        return days
    }
    
    func process(sections: [ServerSection], inDay day: IDUDay, speakers: [String:IDUSpeaker], locations: [String:IDULocation]) -> [IDUSection] {
        var iduSections = [IDUSection]()
        
        sections.forEach { section in
            let iduSection = IDUSection(recordName: section.recordName, name: section.name, day: day)
            iduSection.sessions = process(sessions: section.sessions, inSection: iduSection, speakers: speakers, locations: locations)
            iduSections.append(iduSection)
        }
        
        return iduSections
    }
    
    func process(sessions: [ServerSession], inSection section: IDUSection, speakers: [String:IDUSpeaker], locations: [String:IDULocation]) -> [IDUSession] {
        var iduSessions = [IDUSession]()
        
        sessions.forEach { session in
            let iduSession = IDUSession(recordName: session.recordName, start: session.startTime, end: session.endTime, section: section)
            
            iduSession.sessionItems = process(sessionItems: session.sessionItems, inSession: iduSession, addingSpeakers: speakers, withLocations: locations )
            
            iduSessions.append(iduSession)
        }
        
        return iduSessions
    }
    
    func process(sessionItems: [ServerSessionItem], inSession session: IDUSession, addingSpeakers speakerDictionary: [String:IDUSpeaker], withLocations locations: [String:IDULocation]) -> [IDUSessionItem] {
        
        var iduSessionItems = [IDUSessionItem]()
        
        //let locations = locationDictionary()
        
        sessionItems.forEach { sessionItem in
            let iduSessionItem = IDUSessionItem(recordName: sessionItem.recordName, title: sessionItem.title, content: sessionItem.content, type: sessionItem.type, session: session)
            
            if let frontScreen = sessionItem.listOnFrontScreen {
                iduSessionItem.listOnFrontScreen = frontScreen
            }
            
            sessionItem.speakerRecordNames.forEach { speakerRecordName in
                if let speaker = speakerDictionary[speakerRecordName] {
                    iduSessionItem.speakers.append(speaker)
                    speaker.sessionItems.append(iduSessionItem)
                }
            }
            
            if let location = locations[sessionItem.locationRecordName] {
                iduSessionItem.location = location
            }
            
            iduSessionItems.append(iduSessionItem)
        }
        
        return iduSessionItems
    }
    
    func sessionItems() -> [IDUSessionItem] {
        var sessionItemList = [IDUSessionItem]()
        
        dayList.forEach { day in
            day.sections.forEach { section in
                section.sessions.forEach { session in
                    session.sessionItems.forEach { sessionItem in
                        sessionItemList.append(sessionItem)
                    }
                }
            }
        }
        
        return sessionItemList
    }
    
    func speakerList(addingLinks webLinks: [String:IDUWebLink]) -> [IDUSpeaker] {
        
        return serverData.speakers.map { speaker -> IDUSpeaker in
            let iduSpeaker = IDUSpeaker(recordName: speaker.recordName, name: speaker.name, biography: speaker.biography)
            iduSpeaker.twitterId = speaker.twitterId
            iduSpeaker.imageVersion = speaker.imageVersion
            
            if let recordNames = speaker.webLinkRecordNames {
                recordNames.forEach { webLinkRecordName in
                    if let webLink = webLinks[webLinkRecordName] {
                        iduSpeaker.webLinks.append(webLink)
                    }
                }
            }
            
            return iduSpeaker
        }
    }
    
    var speakerDictionary: [String:IDUSpeaker] {
        
        var speakerDictionary = [String:IDUSpeaker]()
        
        speakerList.forEach { speaker in
            speakerDictionary[speaker.recordName] = speaker
        }
        
        return speakerDictionary
    }
    
    func webLinkDictionary() -> [String:IDUWebLink] {
        
        var webLinkDictionary = [String:IDUWebLink]()
        
        serverData.webLinks.forEach { webLink in
            webLinkDictionary[webLink.recordName] = IDUWebLink(name: webLink.name, url: webLink.url)
        }
        
        return webLinkDictionary
    }
    
    lazy var locationTypeList: [IDULocationType] = {
        return serverData.locationTypes.map { locationType -> IDULocationType in
            return IDULocationType(recordName: locationType.recordName,
                                   name: locationType.name,
                                   order: locationType.order)
        }
    }()
    
    func processLocations(locationTypes: [IDULocationType], links webLinks: [String:IDUWebLink]) -> [IDULocation] {
        
        var dictionary = [String:IDULocationType]()
                
        locationTypes.forEach { locationType in
            dictionary[locationType.recordName] = locationType
        }
        
        return serverData.locations.map { location -> IDULocation in
            
            let iduLocation = IDULocation(recordName: location.recordName,
                               name: location.name,
                               shortName: location.shortName,
                               frontListPosition: location.frontListPosition,
                               showImage: location.showImage,
                               latitude: location.latitude,
                               longitude: location.longitude)
            
            if let note = location.note {
                iduLocation.note = note
            }
            
            if let type = dictionary[location.locationTypeRecordName] {
                type.locations.append(iduLocation)
                iduLocation.locationType = type
            }
            
            if let linkName = location.webLinkRecordName {
                iduLocation.webLink = webLinks[linkName]
            }
            
            return iduLocation
        }
        
    }
    
    func locationDictionary() -> [String:IDULocation] {
        var dictionary = [String:IDULocation]()
     
        locationList.forEach { location in
            dictionary[location.recordName] = location
        }
        
        return dictionary
    }
    
    lazy var sessionItemDictionary: [String:IDUSessionItem] = {
        var dictionary = [String:IDUSessionItem]()
        
        sessionItems().forEach { item in
            dictionary[item.recordName] = item
        }
        
        return dictionary
    }()
    
    
}
