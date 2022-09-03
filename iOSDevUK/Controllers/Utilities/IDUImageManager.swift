//
//  ImageManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2022.
//  Copyright © 2022 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

class IDUImageManager {
    
    private var serverBaseUrl: URL?
    
    init(serverURL: String) {
        self.serverBaseUrl = URL(string: serverURL)
        speakerImages = loadImageData(forCategory: .speakers)
        locationImages = loadImageData(forCategory: .locations)
        sponsorImages = loadImageData(forCategory: .sponsors)
    }
    
    // MARK: Image Metadata
    
    var speakerImages = [String:Int]()
    
    var locationImages = [String:Int]()
    
    var sponsorImages = [String:Int]()
    
    func loadImageData(forCategory category: AppImageCategory) -> [String:Int] {
        do {
            var imageData = [String:Int]()
            
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let imageDirectory = cacheDirectory.appendingPathComponent(category.rawValue, isDirectory: true)
            
            if FileManager.default.fileExists(atPath: imageDirectory.path) {
                let items = try FileManager.default.contentsOfDirectory(atPath: imageDirectory.path)
                
                items.forEach { fileName in
                    if fileName.hasSuffix(".png") {
                        let name = fileName.replacingOccurrences(of: ".png", with: "")
                        let parts = name.split(separator: "-")
                        imageData[String(parts[0])] = Int(String(parts[1]))
                    }
                }
            }
            else {
                print("does not exist: \(imageDirectory.path)")
            }
            
            return imageData
            
        }
        catch let error as NSError {
            debugPrint("Problem accessing speaker image data list \(error)")
            return [String:Int]()
        }
    }
    
    // MARK: Utility
    
    private func createDirectoryIfNeeded(for url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /**
     Check if a name exists with the pattern `category/name-version.png`, e.g. `speakers/AliceEclair-0.png`. The `caches` directory
     is checked.
    
     - Parameter name: The name for the image, e.g. `AliceEclair`.
     - Parameter category: The category that is used to define the subdirectory to check.
     - Parameter version: The version number for the image.
    
     */
    func imageExists(forName name: String, withCategory category: AppImageCategory, withVersion version: Int) -> Bool {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl = cachesDirectory.appendingPathComponent("\(category.rawValue)/\(name)-\(version).png", isDirectory: false)
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    // MARK: Image Download
    
    /**
     
     */
    func loadImage(withName name: String, inCategory category: AppImageCategory) -> UIImage? {
        if let imageVersion = getImageInformation(forCategory: category)[name] {
            
            let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let imageUrl = cachesUrl.appendingPathComponent("\(category.rawValue)/\(name)-\(imageVersion).png", isDirectory: false)
            
           //print("loadImage: trying to get image for: \(name) at \(imageUrl)")
           if let data = try? Data(contentsOf: imageUrl),
              let image = UIImage(data: data) {
                //print("loadImage: returning the image")
                return image
           }
           else if let assetImage = UIImage(named: name) {
                //print("loadImage: checking if can retrieve from central store instead")
                return assetImage
           }
        }
        
        //print("loadImage: no success getting image for \(name)")
        return nil
    }
    
    private func getImageInformation(forCategory category: AppImageCategory) -> [String:Int] {
        switch category {
        case .speakers:
            return speakerImages
        case .locations:
            return locationImages
        case .sponsors:
            return sponsorImages
        }
    }
    
    private func setImageInformation(_ data: [String:Int], forCategory category: AppImageCategory) {
        switch category {
        case .speakers:
            speakerImages = data
            break
        case .locations:
            locationImages = data
            break
        case .sponsors:
            sponsorImages = data
            break
        }
    }
    
    /**
     Given a set of image data, check if the image for the given version is available locally. If the image is not available,
     try to download from the server.
     */
    func checkAndDownloadIfMissing(_ images: [(String, AppImageCategory, Int)]) async {
        for (name, category, version) in images {
            
            let imageData = getImageInformation(forCategory: category)
            
            print("Image data for \(name) with version \(version): \(imageData)")
            var download = true
            if let imageVersion = imageData[name] {
                if imageVersion >= version {
                    download = false
                }
            }
            
            if download {
                if let url = serverBaseUrl?.appendingPathComponent("images/\(category)/\(name).jpg", isDirectory: false) {
                    await processImageAsync(withName: name, category: category, version: version,for: url)
                }
            }
        }
        print("----------- finshed check and download ----")
    }
    
    private func updateImageInformation(withName name: String, category: AppImageCategory, version: Int) {
        var imageInformation = getImageInformation(forCategory: category)
        
        if let previousVersion = imageInformation[name] {
            let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let previousUrl = cachesUrl.appendingPathComponent("\(category.rawValue)/\(name)-\(previousVersion).png", isDirectory: false)
            do {
                //print("**** removing files \(previousUrl)")
                try FileManager.default.removeItem(at: previousUrl)
            }
            catch let error as NSError {
                print("error trying to remove previous version: \(error)")
            }
        }
        
        imageInformation[name] = version
        setImageInformation(imageInformation, forCategory: category)
    }
    
    func processImageAsync(withName name: String, category: AppImageCategory, version: Int, for url: URL) async {
        
        do {
            //print("starting data download for \(name)")
            let (data, response) = try await URLSession.shared.download(from: url)
            //print("download complete for \(name)")
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                debugPrint("unable to access data for \(url)")
                return
            }
            
            let imageData = try Data(contentsOf: data)
                
            if let image = UIImage(data: imageData), let pngData = image.pngData() {
                let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                
                let directory = cachesUrl.appendingPathComponent("\(category.rawValue)", isDirectory: true)
                try createDirectoryIfNeeded(for: directory)
                
                let destinationUrl = cachesUrl.appendingPathComponent("\(category.rawValue)/\(name)-\(version).png", isDirectory: false)
                
                try pngData.write(to: destinationUrl)
                //print("data written to disk at: \(destinationUrl)")
                
                //print("data file exists? \(name): \(FileManager.default.fileExists(atPath: destinationUrl.path))")
                
                updateImageInformation(withName: name, category: category, version: version)
            }
        }
        catch let error as NSError {
            debugPrint("Error during process to store image file. Error: \(error)")
        }
    }
}
