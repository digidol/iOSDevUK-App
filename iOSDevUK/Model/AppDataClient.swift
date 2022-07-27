//
//  AppDataClient.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

enum AppDataClientError: Error {
    case invalidUrl
    case invalidServerResponse
    case invalidData
    case fileStorageError
}

class AppDataClient {
    
    private let session = URLSession(configuration: .default)
    
    private let metadataFile = "metadata.json"
    
    private let scheduleFile = "schedule.json"
    
    private let locationsFile = "locations.json"
    
    /**
     The version for the data file that the app is using.
     */
    private var dataVersion: Int?
    
    /**
     The version of the locations information, used by the app.
     */
    private var locationsVersion: Int?
    
    /**
     The base URL for the different server that holds the metadata, data, locations, sponsor and image data.
     */
    private var serverBaseUrl: URL?
    
    /**
     Initilaises the client with the current data version number.
     
     - Parameters:
     
         - dataVersion: The number of the data that is currently stored in this application. If nil is specified, then no data is currently stored in this app.
     
         - apiBaseUrl: The base URL that is used to access the API functions.
     */
    init() {
        self.serverBaseUrl = URL(string: "https://blue-ocean-0c74f0b03.1.azurestaticapps.net")
    }
    
    /**
     Starts a download. It checks to see if there is local data.
     
     If there is, it will check if there is more recent data on the server.
     If there is no local data, or there is more recent data on the servder, an attempt
     is made to download the remote version.
 
     - Parameters:
     
         - callback: Here is a callback that we can work with.
         - data: The data that has been returned. It might be the data from the server, or
                 the fallback data or `nil` if no data was accessed.
     */
    func loadData(withCallback callback: @escaping (_ data: ServerAppData?) -> Void) {
    }
    
    func loadData() async -> CombinedServerAppData? {
       do {
           
            defer {
                UserDefaults.standard.set(Date(), forKey: "lastUpdatedTime")
            }
           
            var metadata = ServerMetadata()
            if let data = try await fetchMetadata() {
                metadata = data
            }
            
            debugPrint("\(String(describing: metadata))")
            
            let combinedData = CombinedServerAppData()
                
            combinedData.schedule = try await fetchSchedule(serverVersion: metadata.dataVersion)
            debugPrint("\(String(describing: combinedData.schedule))")
            
            combinedData.locations = try await fetchLocations(serverVersion: metadata.locationsVersion)
            debugPrint("\(String(describing: combinedData.locations))")
            
            return combinedData
            
        }
        catch let error as NSError {
            debugPrint("error with the main work \(error)")
            return nil
        }
            
//            downloadMetadata { serverMetadata in
//                var executeCallback = true
//
//                if let metadata = serverMetadata {
//                    if appData.dataVersion < metadata.dataVersion {
//                        self.downloadUpdate(withFallback: appData, processor: callback)
//                        executeCallback = false
//                    }
//                }
//
//                // we don't need to download an update, so we can
//                // run the callback here with no data to pass in
//                if executeCallback {
//                    callback(nil)
//                }
//            }
//        }
//        else {
//            // No local store is available, so start the download
//            downloadUpdate(withFallback: nil, processor: callback)
//        }
        
        
    }
    
    /**
           Load data from a URL and return the data. The source is a .json file that corresponds to a decoable type.
     
            Any failure is returned as an Error, see `Throws` below. Otherwise, the downloaded data is returned.
     
         - Parameter type: The data type to decode and return.
         - Parameter source: The path that will be added to the server URL for the json resource.
     
         - Throws: `AppDataClientError.invalidUrl` if there is a problem building the URL with the given source
         - Throws: `AppDataClientError.invalidServerResponse` if the server does not return a 200 success code
         - Throws: `DecodingError.dataCorrupted(_:)` if there is a problem decoding the data from the server
     
         - Returns: The downloaded data for the given type.
     */
    func fetchData<T>(withType type: T.Type, fromSource source: String) async throws -> T where T : Decodable {
        guard let url = URL(string: source, relativeTo: self.serverBaseUrl) else {
            debugPrint("\(source): Unable to build URL")
            throw AppDataClientError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AppDataClientError.invalidServerResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedData = try decoder.decode(type, from: data)
        return decodedData
    }
    
    func fetchLocations(serverVersion: Int) async throws -> ServerLocationsData? {
        do {
            
            let localData = loadExistingDataFromLocalStore(withType: ServerLocationsData.self, inFile: locationsFile)
            
            if let local = localData {
                if local.dataVersion >= serverVersion {
                    return localData
                }
            }
            
            let data = try await fetchData(withType: ServerLocationsData.self, fromSource: "data/\(locationsFile)")
            
            let success = storeDataToLocalStore(data: data, inFile: locationsFile)
            if !success {
                return nil
            }
            
            return data
        }
        catch let error as NSError {
            debugPrint("Error raised when fetching the locations: \(error)")
            return nil
        }
    }
    
    /**
        Returns the current version of the schedule, which is either loaded from the local store or retrieved from the server.
     
        If there is a local version stored, the version number is checked against the parameter. If the server version is greater, then it is downloaded.
        If there is a problem during the download, and there is a local version, then the local version is returned. If there is a problem with the download
        but there is no local version, then nil is returned.
     
       - Parameter serverVersion: The version number for the data on the server. Used to check if the server
                             version needs to be downloaded.
     
       - Returns: If a local version or update from the server is available, that is returned. If neither is available
           then `nil` is returned.
     
       - Throws: `AppDataClientError.invalidServerResponse` if there was a problem accessing ... ?
     
       - Throws: `AppDataClientError.fileStorageError` if there was a problem accessing ... ?
        
     */
    func fetchSchedule(serverVersion: Int) async throws -> ServerAppData? {
        
        do {
            
            let localSchedule = loadExistingDataFromLocalStore(withType: ServerAppData.self, inFile: scheduleFile)
            
            if let local = localSchedule {
                if local.dataVersion >= serverVersion {
                    return localSchedule
                }
            }
            
            let data = try await fetchData(withType: ServerAppData.self, fromSource: "data/\(scheduleFile)")
            
            let success = storeDataToLocalStore(data: data, inFile: scheduleFile)
            if !success {
                return nil
            }
            
            return data
        }
        catch let error as NSError {
            debugPrint("Error raised when fetching the schedule: \(error)")
            return nil
        }
    }
    
    func fetchMetadata() async throws -> ServerMetadata? {
        return try await fetchData(withType: ServerMetadata.self, fromSource: "data/\(metadataFile)")
    }
        
//        guard let url = URL(string: "data/metadata.json", relativeTo: self.serverBaseUrl) else {
//            print("unable to build URL")
//            return
//        }
//
//        let task = session.dataTask(with: url) {
//                    (data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//            if let downloadedData = data {
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
//                    let decodedData = try decoder.decode(ServerMetadata.self, from: downloadedData)
//                    processor(decodedData)
//                }
//                catch let error as NSError {
//                    print("There was an error: \(error)")
//                    processor(nil)
//                }
//            }
//            else {
//                print("hmm, unable to access the data")
//                processor(nil)
//            }
//
//        }
//
//        task.resume()
//    }
    
    /**
     Get the location for the documents directory.
     
     Credit: Taken from [Hacking with Swift](https://www.hackingwithswift.com/example-code/system/how-to-find-the-users-documents-directory) example.
     
     - Returns: A URL for the documents directory for this app.
     */
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func imageExists(forName name: String) -> Bool {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cachesDirectory.appendingPathComponent("\(name).png", isDirectory: false)
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    /**
          Returns the local copy of the schedule, if it is been downloaded. Otherwise, `nil` is returned.
     */
    /*func loadExistingScheduleDataFromLocalStore() -> ServerAppData? {
        
        let dataFile = getDocumentsDirectory().appendingPathComponent(scheduleFile)
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            if let content = FileManager.default.contents(atPath: dataFile.path) {
                return decodeData(withType: ServerAppData.self, fromData: content)
            }
        }
        
        debugPrint("Unable to access local file with schedule data")
        return nil
    }*/
    
    func loadExistingDataFromLocalStore<T>(withType type: T.Type, inFile file: String) -> T? where T : Decodable {
        let dataFile = getDocumentsDirectory().appendingPathComponent(file)
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            if let content = FileManager.default.contents(atPath: dataFile.path) {
                return decodeData(withType: type, fromData: content)
            }
        }
        
        debugPrint("Unable to access local file for \(file) data")
        return nil
    }
    
    /**
           Stores the given data to a specified file in the documents directory.
     
           - Parameter data: The data of the specified, encodable type.
           - Parameter file: The name of the file to store the data to.
     
           - Returns: `true` if the save is successful, otherwise `false`.
     */
    func storeDataToLocalStore<T>(data: T, inFile file: String) -> Bool where T : Encodable {
        let dataFile = getDocumentsDirectory().appendingPathComponent(file)
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            do {
                try FileManager.default.removeItem(at: dataFile)
            }
            catch let error as NSError {
                debugPrint("Error deleting file: \(error)")
                return false
            }
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encodedData = try encoder.encode(data)
            FileManager.default.createFile(atPath: dataFile.path, contents: encodedData, attributes: nil)
        }
        catch let error as NSError {
            debugPrint("Unable to store file: \(error)")
            return false
        }
        
        return true
    }
    
    /*func storeScheduleToLocalStore(appData: ServerAppData) -> Bool {
        let dataFile = getDocumentsDirectory().appendingPathComponent(scheduleFile)
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            do {
                try FileManager.default.removeItem(at: dataFile)
            }
            catch let error as NSError {
                debugPrint("Error deleting file: \(error)")
                return false
            }
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(appData)
            FileManager.default.createFile(atPath: dataFile.path, contents: data, attributes: nil)
        }
        catch let error as NSError {
            debugPrint("Unable to store file: \(error)")
            return false
        }
        
        return true
    }*/
    
    /*private func decodeAppData(data: Data) -> ServerAppData? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ServerAppData.self, from: data)
        }
        catch let error as NSError {
            print("There was an error: \(error)")
            return nil
        }
    }*/
    
    /**
      Decodes a set of data to data of the given type, `T`.
     
      - Parameter type The type that the decode should use to bulid the data.
      - Parameter data The data that contains the information to be decoded.
     
      - Returns The data of the given type, if it was possible to decode to the given type. Otherwise, `nil` is returned.
     */
    private func decodeData<T>(withType type: T.Type, fromData data: Data) -> T? where T : Decodable {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        }
        catch let error as NSError {
            print("There was an error: \(error)")
            return nil
        }
    }
    
    /**
     Access the metadata information.
     
     - Parameters:
     
         - processor: A closure that will be called when the network access has completed and an attempt has been made to extract the data. If the data was successfully extracted, it is passed to the processor. If there was a problem accessing the metadata, then `nil` is passed as a parameter.
     */
    /*func downloadMetadata(withProcessor processor: @escaping (ServerMetadata?) -> Void) {
        guard let url = URL(string: "data/metadata.json", relativeTo: self.serverBaseUrl) else {
            print("unable to build URL")
            return
        }
                
        let task = session.dataTask(with: url) {
                    (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            if let downloadedData = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decodedData = try decoder.decode(ServerMetadata.self, from: downloadedData)
                    processor(decodedData)
                }
                catch let error as NSError {
                    print("There was an error: \(error)")
                    processor(nil)
                }
            }
            else {
                print("hmm, unable to access the data")
                processor(nil)
            }
        
        }
        
        task.resume()
    }*/
    
    /**
     Requests the most recent update. When the data has been successfully downloaded, the
     processor is called. If it is called with data, it is the data that was downloaded. If it is called with the
     value `nil` then there was a problem accessing the file.
     
     - Parameters:
         - fallbackData: If there is a problem accessing the remote data, this data is passed to the `processor()`.
         - processor: Called when the download operation has completed.
     */
    /*func downloadUpdate(withFallback fallbackData: ServerAppData?, processor: @escaping (ServerAppData?) -> Void) {
        
        guard let url = URL(string: "data/schedule.json", relativeTo: self.serverBaseUrl) else {
            debugPrint("unable to build URL")
            return
        }
        
        let task = session.dataTask(with: url) {
                    (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            if let downloadedData = data {
                debugPrint("data accessed: \(downloadedData)")
                
                if let appData = self.decodeAppData(data: downloadedData) {
                    // successfully accessed data from a remote source
                    // store a copy in the documents directory
                    if !self.storeScheduleToLocalStore(appData: appData) {
                        debugPrint("Error storing file")
                    }
                    processor(appData)
                }
                else {
                    debugPrint("Unable to access remote data, returning any fallback data")
                    processor(fallbackData)
                }
            }
            else {
                debugPrint("hmm, unable to access the data, returning any fallback data")
                processor(fallbackData)
            }
        }
        
        task.resume()
    }*/
    
    var pendingDataTasks = [String:URLSessionDownloadTask]()
    
    /**
     
     */
    func downloadImages(_ images: [String], withCallback callback: @escaping () -> Void) {
        
        images.forEach { name in
            
            if let url = serverBaseUrl?.appendingPathComponent("image", isDirectory: false),
               var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.query = "n=\(name)"
                
                if let url = urlComponents.url {
                    
                    let task = session.downloadTask(with: URLRequest(url: url), completionHandler: {
                        url, response, error in
                        
                        debugPrint("finished task for \(name)")
                        debugPrint(String(describing: url))
                        
                        do {
                            if let downloadUrl = url {
                                
                                let imageData = try Data(contentsOf: downloadUrl)
                                
                                if let image = UIImage(data: imageData),
                                    let pngData = image.pngData() {
                                    let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                                    let destinationUrl = cachesUrl.appendingPathComponent("\(name).png", isDirectory: false)
                                    try pngData.write(to: destinationUrl)
                                }
                            }
                        } catch let error as NSError {
                            print("Error copying file: \(error)")
                        }
                        
                        // remove the task, even if we failed on the copy. We can try again later on.
                        self.pendingDataTasks.removeValue(forKey: name)
                        print("Number of pending tasks: \(self.pendingDataTasks.count)")
                        
                        if self.pendingDataTasks.count == 0 {
                            callback()
                        }
                    })
                    
                    self.pendingDataTasks[name] = task
                    print("starting task for \(name) (of \(self.pendingDataTasks.count) tasks)")
                    task.resume()
                }
            }
        }
    }
    
    
}
