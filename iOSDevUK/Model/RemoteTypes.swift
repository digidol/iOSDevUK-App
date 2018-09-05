//
//  RemoteTypes.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 29/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation

enum RemoteDay {
    static let date = "date"
}

enum RemoteLocation {
    static let active = "active"
    static let frontListPosition = "frontListPosition"
    static let location = "location"
    static let name = "name"
    static let note = "note"
    static let shortName = "shortName"
    static let showImage = "showImage"
    static let locationType = "locationType"
    static let webLink = "webLink"
}

enum RemoteLocationType {
    static let name = "name"
    static let order = "order"
    static let note = "note"
}

enum RemoteSection {
    static let name = "name"
    static let recordName = "recordName"
    static let footer = "footer"
    static let header = "header"
    static let day = "day"
}

enum RemoteSession {
    static let startTime = "startTime"
    static let endTime = "endTime"
    static let recordName = "recordName"
    static let name = "name"
    static let type = "type"
    static let section = "section"
}

enum RemoteSessionItem {
    static let active = "active"
    static let content = "content"
    static let listOnFrontScreen = "listOnFrontScreen"
    static let order = "order"
    static let recordName = "recordName"
    static let title = "title"
    static let type = "type"
    static let location = "location"
    static let session = "session"
    static let speakers = "speakers"
}

enum RemoteSpeaker {
    static let biography = "biography"
    static let linkedIn = "linkedIn"
    static let name = "name"
    static let recordName = "recordName"
    static let twitterId = "twitterId"
    static let sessionItems = "sessionItems"
    static let webLinks = "webLinks"
}

enum RemoteSponsor {
    static let active = "active"
    static let name = "name"
    static let recordName = "recordName"
    static let sponsorCategory = "sponsorCategory"
    static let sponsorOrder = "sponsorOrder"
    static let tagline = "tagline"
    static let url = "url"
    static let cellType = "cellType"
    static let note = "note"
}

enum RemoteWebLink {
    static let active = "active"
    static let name = "name"
    static let recordName = "recordName"
    static let url = "url"
}
