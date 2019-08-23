//
//  AppDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation

/**
 
 */
protocol AppDataManager {
    
    func settings() -> AppSettings
    
    func currentTime() -> Date
    
    /**
     Returns the start date from the data that has been loaded.
         
     - Returns: A date is returned or, if the conference data is not yet available, the value `nil` is returned.
    */
    func startDate() -> Date?
    
    /**
     Returns the end date from the data that has been loaded.
         
     - Returns: A date is returned or, if the conference data is not yet available, the value `nil` is returned.
    */
    func endDate() -> Date?
    
    func setAlternativeDate(_ date: Date)
    
    func initialiseData(onCompletion callback: @escaping (Bool, String?) -> Void)
    
    func days() -> [IDUDay]
    
    func sessionItems() -> [IDUSessionItem]
    
    func sponsors() -> [ServerSponsor]
    
    func speakers() -> [IDUSpeaker]
    
    func locations() -> [IDULocation]
    
    func locationTypes() -> [IDULocationType]
    
    func sessionItemDictionary() -> [String:IDUSessionItem]
    
    func isDataLoaded() -> Bool
    
    func addObserver(_ observer: AppDataObserver)
    
    func removeObserver(_ observer: AppDataObserver)
    
    func image(recordName: String) -> URL?
    
    func nowSession(forDate date: Date) -> IDUSession?
    
    func nextSession(forDate date: Date) -> IDUSession?
}


protocol AppDataObserver: class {
    
    /**
     Called when the data has been updated. Any responding function can then initiate an update to the UI.
     */
    func appDataUpdated()

    /**
     Called if there is a problem loading the data.
     */
    func appDataFailedToLoad(withReason reason: String)
}





class ServerAppDataManager: AppDataManager {
    
    func image(recordName: String) -> URL? {
        return nil
    }
    
    
    
    func sessionItemDictionary() -> [String : IDUSessionItem] {
        return appDataWrapper?.sessionItemDictionary ?? [:]
    }
    
    private var appSettings = IDUAppSettings()
    
    func settings() -> AppSettings {
        return appSettings
    }
    
    private var appDataWrapper: IDUAppDataWrapper?
    
    func startDate() -> Date? {
        return data?.startDate ?? nil
    }
    
    
    func nowSession(forDate date: Date) -> IDUSession? {
        
        let filter = { (session: IDUSession) throws -> Bool in
            return session.startTime <= date && session.endTime >= date
        }
        
        let sorter = { (session1: IDUSession, session2: IDUSession) throws -> Bool in
            session1.startTime < session2.startTime
        }
        
        if let sessions = appDataWrapper?.sessions(filteredWith: filter, sortedBy: sorter) {
            if sessions.count > 0 {
                return sessions[0]
            }
        }
        
        return nil
    }
    
    func nextSession(forDate date: Date) -> IDUSession? {
        
        let filter = { (session: IDUSession) throws -> Bool in
            return session.startTime > date
        }
        
        let sorter = { (session1: IDUSession, session2: IDUSession) throws -> Bool in
            session1.startTime < session2.startTime
        }
        
        if let sessions = appDataWrapper?.sessions(filteredWith: filter, sortedBy: sorter) {
            if sessions.count > 0 {
                return sessions[0]
            }
        }
        
        return nil
    }
    
    
    
    
    
    /**
     Returns the end date from the data that has been loaded.
          
     - Returns: A date is returned or, if the conference data is not yet available, the value `nil` is returned.
     */
    func endDate() -> Date? {
        return data?.endDate ?? nil
    }
    
    private var data: ServerAppData?
    
    var alternativeTime: Date?
        
    func currentTime() -> Date {
        return alternativeTime ?? Date()
    }
    
    func setAlternativeDate(_ date: Date) {
        alternativeTime = date
    }
    
    /**
     Initialise the database by
     */
    func initialiseData(onCompletion callback: @escaping (Bool, String?) -> Void) {
        
        let client = AppDataClient()
        
        client.loadData { appData in
            if let data = appData {
                self.data = data
                self.appDataWrapper = IDUAppDataWrapper(serverData: data)
                self.processSpeakerImages()
                self.processSponsorImages()
                callback(true, nil)
            }
            else {
                print("Unable to retrieve the app data")
                callback(false, "Unable to access app data.")
            }
        }
    }
    
    
    func processSpeakerImages() {
        
        var imagesToLoad = [String]()
        let appDataClient = AppDataClient()
        
        speakers().forEach { speaker in
            
            if speaker.imageVersion != nil && !appDataClient.imageExists(forName: speaker.recordName) {
               imagesToLoad.append(speaker.recordName)
            }
        }
        
        appDataClient.downloadImages(imagesToLoad)
        
    }
    
    func processSponsorImages() {
        
        var imagesToLoad = [String]()
        let appDataClient = AppDataClient()
        
        sponsors().forEach { sponsor in
            
            if sponsor.imageVersion != 0 && !appDataClient.imageExists(forName: sponsor.recordName) {
                imagesToLoad.append(sponsor.recordName)
            }
        }
        
        appDataClient.downloadImages(imagesToLoad)
        
    }
    
    func days() -> [IDUDay] {
        return appDataWrapper?.dayList ?? []
    }
    
    func sessionItems() -> [IDUSessionItem] {
        return appDataWrapper?.sessionItemList ?? []
    }
    
    func sponsors() -> [ServerSponsor] {
        return data?.sponsors ?? []
    }
    
    func speakers() -> [IDUSpeaker] {
        if let list = appDataWrapper?.speakerList {
            return list.sorted { $0.name < $1.name }
        }
        
        return []
    }
    
    func locations() -> [IDULocation] {
        return appDataWrapper?.locationList ?? []
    }
    
    func locationTypes() -> [IDULocationType] {
        return appDataWrapper?.locationTypeList ?? []
    }
    
    func isDataLoaded() -> Bool {
        return data != nil
    }
    
    /**
     A set of observers who would like to be notiifed when there are relevant
     changes to the data.
     */
    private var observers = [ObjectIdentifier : Observation]()
    
    func addObserver(_ observer: AppDataObserver) {
        let id = ObjectIdentifier(observer)
        observers[id] = Observation(observer: observer)
    }
    
    func removeObserver(_ observer: AppDataObserver) {
        let id = ObjectIdentifier(observer)
        observers.removeValue(forKey: id)
    }
    
    
}

private extension ServerAppDataManager {
    
    /**
     An observation that can be placed on the ServerAppDataManager.
     */
    struct Observation {
        weak var observer: AppDataObserver?
    }

}


