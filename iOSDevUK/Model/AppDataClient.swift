//
//  AppDataClient.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

class AppDataClient {
    
    private let session = URLSession(configuration: .default)
    
    /**
     The version for the data file that the app is using.
     */
    private var dataVersion: Int?
    
    /**
     The base URL for the different api functions to get metadata, data and image data.
     */
    private var apiBaseUrl: URL?
    
    /**
     Initilaises the client with the current data version number.
     
     - Parameters:
     
         - dataVersion: The number of the data that is currently stored in this application. If nil is specified, then no data is currently stored in this app.
     
         - apiBaseUrl: The base URL that is used to access the API functions.
     */
    init() {
        self.apiBaseUrl = URL(string: "http://localhost/iosdevuk_server/api/")
        //self.apiBaseUrl = URL(string: "https://teaching.dcs.aber.ac.uk/iosdevuk/api/")
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
        if let appData = loadExistingCopyFromLocalStore() {
            downloadMetadata { serverMetadata in
                var executeCallback = true
                
                if let metadata = serverMetadata {
                    if appData.dataVersion < metadata.dataVersion {
                        self.downloadUpdate(withFallback: appData, processor: callback)
                        executeCallback = false
                    }
                }
                
                // we don't need to download an update, so we can
                // run the callback here with no data to pass in
                if executeCallback {
                    callback(nil)
                }
            }
        }
        else {
            // No local store is available, so start the download
            downloadUpdate(withFallback: nil, processor: callback)
        }
        
        UserDefaults.standard.set(Date(), forKey: "lastUpdatedTime")
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
    
    func loadExistingCopyFromLocalStore() -> ServerAppData? {
        
        let dataFile = getDocumentsDirectory().appendingPathComponent("data.json")
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            if let content = FileManager.default.contents(atPath: dataFile.path) {
                return decodeAppData(data: content)
            }
        }
        
        print("Unable to access local file")
        return nil
        
    }
    
    func storeToLocalStore(appData: ServerAppData) -> Bool {
        let dataFile = getDocumentsDirectory().appendingPathComponent("data.json")
        
        if FileManager.default.fileExists(atPath: dataFile.path) {
            do {
                try FileManager.default.removeItem(at: dataFile)
            }
            catch let error as NSError {
                print("Error deleting file: \(error)")
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
            print("Unable to store file: \(error)")
            return false
        }
        
        return true
    }
    
    private func decodeAppData(data: Data) -> ServerAppData? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ServerAppData.self, from: data)
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
    func downloadMetadata(withProcessor processor: @escaping (ServerMetadata?) -> Void) {
        guard let url = URL(string: "metadata", relativeTo: self.apiBaseUrl) else {
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
    }
    
    /**
     Requests the most recent update. When the data has been successfully downloaded, the
     processor is called. If it is called with data, it is the data that was downloaded. If it is called with the
     value `nil` then there was a problem accessing the file.
     
     - Parameters:
     
         - processor: Called when the download operation has completed.
     */
    func downloadUpdate(withFallback fallbackData: ServerAppData?, processor: @escaping (ServerAppData?) -> Void) {
        
        guard let url = URL(string: "schedule", relativeTo: self.apiBaseUrl) else {
            print("unable to build URL")
            return
        }
        
        let task = session.dataTask(with: url) {
                    (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            if let downloadedData = data {
                print("data accessed: \(downloadedData)")
                
                if let appData = self.decodeAppData(data: downloadedData) {
                    // successfully accessed data from a remote source
                    // store a copy in the documents directory
                    if !self.storeToLocalStore(appData: appData) {
                        print("Error storing file")
                    }
                    processor(appData)
                }
                else {
                    print("Unable to access remote data, returning any fallback data")
                    processor(fallbackData)
                }
            }
            else {
                print("hmm, unable to access the data, returning any fallback data")
                processor(fallbackData)
            }
        }
        
        task.resume()
    }
    
    var pendingDataTasks = [String:URLSessionDownloadTask]()
    
    /**
     
     */
    func downloadImages(_ images: [String], withCallback callback: @escaping () -> Void) {
        
        images.forEach { name in
            
            if let url = apiBaseUrl?.appendingPathComponent("image", isDirectory: false),
               var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.query = "n=\(name)"
                
                if let url = urlComponents.url {
                    
                    let task = session.downloadTask(with: URLRequest(url: url), completionHandler: {
                        url, response, error in
                        
                        print("finished task for \(name)")
                        print(String(describing: url))
                        
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
