//
//  AppDataClient.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2019.
//  Copyright © 2019-2022 Aberystwyth University. All rights reserved.
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
    
    /** The name for the metadata file. */
    private let metadataFile = "metadata.json"
    
    /** The name for the file with the schdule data (days, sessions, session items, speakers, web links. */
    private let scheduleFile = "schedule.json"
    
    /** The name for the file with the locations data (location types and locations). */
    private let locationsFile = "locations.json"
    
    /** URL of the server that hosts the data. */
    private let serverURL = "https://blue-ocean-0c74f0b03.1.azurestaticapps.net"
    
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
     Initilaises the client ready to access remote data.
     */
    init() {
        self.serverBaseUrl = URL(string: serverURL)
    }
    
    /**
     Loads the data for the app. A local version is loaded, if it exists. If it is an earlier version, or there is no local version, then
       the data is loaded from the server.
     
      - Returns: If data was loaded, then it is returned in the compound object that collects the data for use in the app. If there was an error thrown during the process, `nil` will be returned. The code aims to trap common problems and return `nil` for the relevant part in the compound object. If `nil` is returned from this method, a more significiant problem has happened.
     */
    func loadData() async -> CombinedServerAppData? {
        do {
            defer {
                UserDefaults.standard.set(Date(), forKey: "lastUpdatedTime")
            }
           
            let metadata = await fetchMetadata()
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
     
     If there is a local version stored, the version number is checked against the parameter. If the server version is greater, then it is downloaded. If there is a problem during the download, and there is a local version, then the local version is returned. If there is a problem with the download but there is no local version, then nil is returned.
     
     - Parameter serverVersion: The version number for the data on the server. Used to check if the server
                             version needs to be downloaded.
     
     - Returns: If a local version or update from the server is available, that is returned. If neither is available
           then `nil` is returned.
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
    
    /**
     Fetches the metadata from the server. 
     */
    func fetchMetadata() async -> ServerMetadata {
        
        var metadata = ServerMetadata()
       
        do {
            metadata = try await fetchData(withType: ServerMetadata.self, fromSource: "data/\(metadataFile)")
        }
        catch let error as NSError {
            debugPrint("Unable to access metadata. Default version to be used. \(error)")
        }
        
        return metadata
    }
    
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
    
    var pendingDataTasks = [String:URLSessionDownloadTask]()
    
    func processImage(withName name: String, for url: URL) {
        
        Task {
            do {
                let (location, response) = try await URLSession.shared.download(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    debugPrint("unable to access data for \(url)")
                    return
                }
                
                let imageData = try Data(contentsOf: location)
                    
                if let image = UIImage(data: imageData),
                    let pngData = image.pngData() {
                    let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let destinationUrl = cachesUrl.appendingPathComponent("\(name).png", isDirectory: false)
                    try pngData.write(to: destinationUrl)
                }
            }
            catch let error as NSError {
                debugPrint("Error accessing image file \(error)")
            }
        }
    }
    
    func processImageAsync(withName name: String, for url: URL) async {
        
        do {
            let (location, response) = try await URLSession.shared.download(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                debugPrint("unable to access data for \(url)")
                return
            }
            
            let imageData = try Data(contentsOf: location)
                
            if let image = UIImage(data: imageData), let pngData = image.pngData() {
                let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let destinationUrl = cachesUrl.appendingPathComponent("\(name).png", isDirectory: false)
                try pngData.write(to: destinationUrl)
                debugPrint("stored data for: \(url)")
            }
        }
        catch let error as NSError {
            debugPrint("Error accessing image file \(error)")
        }
    }
    
    func downloadImages(_ images: [String]) async {
        for name in images {
            if let url = serverBaseUrl?.appendingPathComponent("images/speakers/\(name).jpg", isDirectory: false) {
                await processImageAsync(withName: name, for: url)
            }
        }
    }
}
