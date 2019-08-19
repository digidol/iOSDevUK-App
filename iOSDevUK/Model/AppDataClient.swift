//
//  AppDataClient.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation

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
    init(dataVersion: Int?) {
        self.dataVersion = dataVersion
        self.apiBaseUrl = URL(string: "http://localhost/iosdevuk_server/api/")
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
                    let data = try decoder.decode(ServerMetadata.self, from: downloadedData)
                    processor(data)
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
    func downloadUpdate(withProcessor processor: @escaping (ServerAppData?) -> Void) {
        
        guard let url = URL(string: "schedule", relativeTo: self.apiBaseUrl) else {
            print("unable to build URL")
            return
        }
        
        let task = session.dataTask(with: url) {
                    (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            if let downloadedData = data {
                print("data accessed: \(downloadedData)")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let data = try decoder.decode(ServerAppData.self, from: downloadedData)
                    processor(data)
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
     
     */
    func downloadImages(_ images: [String], withCallback: (Bool) -> Void) {
        
    }
    
    
}
