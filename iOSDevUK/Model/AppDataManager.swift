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
    
    func isDataLoaded() -> Bool
    
    func addObserver(_ observer: AppDataObserver)
    
    func removeObserver(_ observer: AppDataObserver)
    
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
    
    private var dayList: [IDUDay]?
    
    private var speakerList: [IDUSpeaker]?
    
    private var sessionItemList: [IDUSessionItem]?
    
    private var locationList: [IDULocation]?
    
    private var locationTypeList: [IDULocationType]?
    
    
    
    func startDate() -> Date? {
        return data?.startDate ?? nil
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
        
    }
    
    func initialiseData(onCompletion callback: @escaping (Bool, String?) -> Void) {
        
        let client = AppDataClient(dataVersion: nil)
                
        client.downloadMetadata{ (data) in
            if data != nil {
                client.downloadUpdate { (data) in
                    print("Download returned \(String(describing: data))")
                    self.data = data
                    
                    if let serverData = data {
                        let initialiser = IDUAppDataInitialiser(serverData: serverData)
                        self.dayList = initialiser.dayList
                        self.speakerList = initialiser.speakerList
                        self.sessionItemList = initialiser.sessionItems
                        self.locationList = initialiser.locationList
                        self.locationTypeList = initialiser.locationTypeList
                        print("processed the list of days")
                    }
                    
                    callback(true, nil)
                }
            } else {
                print("Unable to retrieve the metadata")
                callback(false, "Unable to access metadata.")
            }
        }
    }
    
    func days() -> [IDUDay] {
        return dayList ?? []
    }
    
    func sessionItems() -> [IDUSessionItem] {
        return sessionItemList ?? []
    }
    
    func sponsors() -> [ServerSponsor] {
        return data?.sponsors ?? []
    }
    
    func speakers() -> [IDUSpeaker] {
        if let list = speakerList {
            return list.sorted { $0.name < $1.name }
        }
        
        return []
    }
    
    func locations() -> [IDULocation] {
        return locationList ?? []
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


