//
//  AppDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2019.
//  Copyright © 2019-2022 Aberystwyth University. All rights reserved.
//

import Foundation

protocol AppDataManager {
    
    func shouldTryRemoteUpdate() -> Bool
    
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
    
    func initialiseData(onCompletion callback: @escaping (Bool) -> Void, afterImageDownload imageCallback: @escaping () -> Void)
    
    func days() -> [IDUDay]
    
    func sessionItems() -> [IDUSessionItem]
    
    func sponsors() -> [ServerSponsor]
    
    func speakers() -> [IDUSpeaker]
    
    func locations() -> [IDULocation]
    
    func locationTypes() -> [IDULocationType]
    
    func sessionItemDictionary() -> [String:IDUSessionItem]
    
    func nowSession(forDate date: Date) -> IDUSession?
    
    func nextSession(forDate date: Date) -> IDUSession?
    
    //func loadLocalData(withImageCallback imageCallback: @escaping () -> Void)
}

class ServerAppDataManager: AppDataManager {
    
    private var appSettings = IDUAppSettings()
    
    private var appDataWrapper: IDUAppDataWrapper?
    
    private var data: CombinedServerAppData?
    
    
    func shouldTryRemoteUpdate() -> Bool {
        if let time = UserDefaults.standard.object(forKey: "lastUpdatedTime") as? Date {
            let minutesAgo = Date().addingTimeInterval(-3600)
            print("Checking for remote update? \(time) and \(minutesAgo)")
            
            return time < minutesAgo
        }
        
        return true
    }
    
    func sessionItemDictionary() -> [String : IDUSessionItem] {
        return appDataWrapper?.sessionItemDictionary ?? [:]
    }
    
    func settings() -> AppSettings {
        return appSettings
    }
    
    // MARK: - Date and Now/Next functions
    
    private var alternativeTime: Date?
    
    func startDate() -> Date? {
        return data?.schedule?.startDate ?? nil
    }
    
    /**
     Returns the end date from the data that has been loaded.
     
     - Returns: A date is returned or, if the conference data is not yet available, the value `nil` is returned.
     */
    func endDate() -> Date? {
        return data?.schedule?.endDate ?? nil
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
    
    func currentTime() -> Date {
        return alternativeTime ?? Date()
    }
    
    func setAlternativeDate(_ date: Date) {
        alternativeTime = date
    }
    
    func setupData(_ data: CombinedServerAppData, withImageCallback imageCallback: @escaping () -> Void) {
        self.data = data
        self.appDataWrapper = IDUAppDataWrapper(serverData: data)
        self.processImages(withCallback: imageCallback)
    }
    
    /**
     Loads local data if it is present.
     
     - Returns: `true` is returned if local data exists and is loaded ready to use. Otherwise, `false` is returned.
     
    func loadLocalData(withImageCallback imageCallback: @escaping () -> Void) {
        let client = AppDataClient()
        // FIXME - investigate what this affects
//        if let localData = client.loadExistingScheduleDataFromLocalStore() {
//            setupData(localData, withImageCallback: imageCallback)
//        }
    }*/
    
    /**
     Initialise the conference data by starting process to check if there is new data. If there is, it is downloaded and a check is made to determine if an images need to be downloaded.
     
     - Parameters:
         - callback: A function that is called when the data load operation is completed. This can be used by calling code to determine if there is data to load or any error messages should be displayed.
         - success: `true` if the data was downloaded. This only confirms that there is new data, not that any associated images have been successfully retrieved. `false` is returned if no data was returned, e.g. lack of network access.
         - message: an optional message. There won't be a message is the success parameter is `true`. There will be a message if there success parameter is `false`.
         - imageCallback: A function that is called when images have been downloaded. This can be used to refresh the display.
     */
    func initialiseData(onCompletion callback: @escaping (_ success: Bool) -> Void,
                        afterImageDownload imageCallback: @escaping () -> Void) {
        
        Task {
            let client = AppDataClient()
            if let combinedData = await client.loadData() {
                setupData(combinedData, withImageCallback: imageCallback)
                debugPrint("Data is setup!")
                callback(true)
            }
            else {
                callback(false)
            }
        }
    }
    
    /**
     Start process to determine if ...
     */
    func processImages(withCallback callback: @escaping () -> Void) {
        
        var imagesToLoad = [String]()
        let appDataClient = AppDataClient()
        
        speakers().forEach { speaker in
            
            if speaker.imageVersion != nil && !appDataClient.imageExists(forName: speaker.recordName) {
               imagesToLoad.append(speaker.recordName)
            }
        }
        
        sponsors().forEach { sponsor in
            
            if sponsor.imageVersion != 0 && !appDataClient.imageExists(forName: sponsor.recordName) {
                imagesToLoad.append(sponsor.recordName)
            }
        }
        
        let images = imagesToLoad
        
        Task {
            await appDataClient.downloadImages(images)
        }
        
        callback()
        
    }
    
    
    func days() -> [IDUDay] {
        return appDataWrapper?.dayList ?? []
    }
    
    func sessionItems() -> [IDUSessionItem] {
        return appDataWrapper?.sessionItemList ?? []
    }
    
    func sponsors() -> [ServerSponsor] {
        // FIXME
        //return data?.sponsors ?? []
        return []
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
    
}


