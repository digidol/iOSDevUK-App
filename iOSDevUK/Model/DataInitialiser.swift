//
//  DataInitialiser.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData

class DataInitialiser {

    let context: NSManagedObjectContext
    
    let formatter = ISO8601DateFormatter()

    init(context: NSManagedObjectContext) {
        self.context = context
        formatter.timeZone = TimeZone(identifier: "Europe/London")
    }
    
    func initialiseData() {
        initialiseVersion1()
    }
    
    private func initialiseVersion1() {
    
        initialiseSponsors()
        initialiseUserSettings()
        
        let days = initialiseDays()
        let sections = initialiseSections(forDays: days)
        let locationTypes = initialiseLocationTypes()
        let locations = initialiseLocations(withLocationTypes: locationTypes)
        let webLinks = initialiseWebLinks()
        let speakers = initialiseSpeakers(withWebLinks: webLinks)
        
        initialiseSessionsAndSessionItemsOnDay1(forSections: sections, withSpeakers: speakers, locations: locations)
        initialiseSessionsAndSessionItemsOnDay2(forSections: sections, withSpeakers: speakers, locations: locations)
        initialiseSessionsAndSessionItemsOnDay3(forSections: sections, withSpeakers: speakers, locations: locations)
        initialiseSessionsAndSessionItemsOnDay4(forSections: sections, withSpeakers: speakers, locations: locations)
        
        // App Settings
        
        var setting = AppSetting.createInstance(inContext: context)
        setting.name = "data-model-version"
        setting.intValue = 20180815
        setting.note = "Initial data with sponsors"
        
        setting = AppSetting.createInstance(inContext: context)
        setting.name = "conference-start-time"
        setting.dateValue = formatter.date(from: "2018-09-03T16:00:00+01:00") as NSDate?
        setting.note = "start date and time"
        
        setting = AppSetting.createInstance(inContext: context)
        setting.name = "conference-end-time"
        setting.dateValue = formatter.date(from: "2018-09-06T16:30:00+01:00") as NSDate?
        setting.note = "end date and time"
        
    }
    
    private func initialiseUserSettings() {
    
        let userSettings = UserSettings.createInstance(inContext: context)
        userSettings.showMySchedulePrompt = true
        
    }
    
    private func initialiseDays() -> Dictionary<String,Day> {
    
        var days = Dictionary<String,Day>()
        
        print(formatter.formatOptions)
        formatter.formatOptions = [.withFullDate]
        
        var day = Day.createInstance(inContext: context)
        day.date = formatter.date(from: "2018-09-03") as NSDate?
        days["2018-09-03"] = day
        
        day = Day.createInstance(inContext: context)
        day.date = formatter.date(from: "2018-09-04") as NSDate?
        days["2018-09-04"] = day
        
        day = Day.createInstance(inContext: context)
        day.date = formatter.date(from: "2018-09-05") as NSDate?
        days["2018-09-05"] = day
        
        day = Day.createInstance(inContext: context)
        day.date = formatter.date(from: "2018-09-06") as NSDate?
        days["2018-09-06"] = day
            
        formatter.formatOptions = [.withInternetDateTime]
        
        return days
    
    }
    
    private func initialiseSponsors() {
    
        var sponsor = Sponsor.createInstance(inContext: context)
        sponsor.recordName = "ctm"
        sponsor.name = "Compare The Market"
        sponsor.tagline = "We challenge, build, learn and grow"
        sponsor.sponsorOrder = 10
        sponsor.url = URL(string: "https://www.bglgroup.co.uk/comparethemarket/life-at")
        sponsor.active = true
        sponsor.sponsorCategory = "Platinum"
        sponsor.cellType = "imageTop"
        sponsor.note = "Sponsoring the main conference meal."
        
        sponsor = Sponsor.createInstance(inContext: context)
        sponsor.recordName = "capital_one"
        sponsor.name = "CapitalOne"
        sponsor.tagline = "Reimagine Money - Inspire Life"
        sponsor.sponsorOrder = 20
        sponsor.sponsorCategory = "Gold"
        sponsor.url = URL(string: "https://www.capitalonecareers.co.uk")
        sponsor.active = true
        sponsor.cellType = "imageRight"
        sponsor.note = "Sponsoring the drinks at the conference meal."
        
        sponsor = Sponsor.createInstance(inContext: context)
        sponsor.recordName = "starlingbank"
        sponsor.name = "Starling Bank"
        sponsor.tagline = "Be part of something brilliant"
        sponsor.sponsorOrder = 30
        sponsor.sponsorCategory = "Gold"
        sponsor.url = URL(string: "https://starlingbank.com/careers/")
        sponsor.active = true
        sponsor.cellType = "imageTop"
        
    }
    
    private func initialiseLocationTypes() -> Dictionary<String,LocationType> {
        var locationTypes = Dictionary<String,LocationType>()
        
        var locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "au"
        locationType.name = "University Locations"
        locationType.order = 1
        locationTypes[locationType.recordName!] = locationType
        
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "transport"
        locationType.name = "Taxis, Trains and Petrol"
        locationType.order = 2
        locationTypes[locationType.recordName!] = locationType
        
        /*
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "eatin"
        locationType.name = "Restaurants"
        locationType.name = "A selection of the restaurants available in town."
        locationType.order = 3
        locationTypes[locationType.recordName!] = locationType
        
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "eatout"
        locationType.name = "Takeways & Chip Shops"
        locationType.note = "A list of some of the takeaways in town."
        locationType.order = 4
        locationTypes[locationType.recordName!] = locationType
        */
        
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "pubs"
        locationType.name = "Pubs"
        locationType.note = "There are lots of places to drink in town. This list is some of those conference attendees have used in the past, but there are plenty more that you can try."
        locationType.order = 5
        locationTypes[locationType.recordName!] = locationType
        
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "sm"
        locationType.name = "Supermarkets"
        locationType.note = "There is a supermarket close to the accommodation area and other supermarkets close to the centre of town."
        locationType.order = 6
        locationTypes[locationType.recordName!] = locationType
        
        /*
        locationType = LocationType.createInstance(inContext: context)
        locationType.recordName = "cafe"
        locationType.name = "Cafes and Coffee Shops"
        locationType.note = "There are lots of cafes in the town. The ones listed are those that are open outside of the main conference times."
        locationType.order = 7
        locationTypes[locationType.recordName!] = locationType
        */
        
        return locationTypes
    }
    
    private func initialiseLocations(withLocationTypes locationTypes: Dictionary<String,LocationType>) -> Dictionary<String,Location> {
        
        var locations = Dictionary<String,Location>()
        
        var location = Location.createInstance(inContext: context)
        location.recordName = "MP-0.15"
        location.name = "Physics Main Lecture Theatre"
        location.shortName = "Physics Main"
        location.frontListPosition = 10
        location.active = true
        location.showImage = true
        location.latitude = 52.415941
        location.longitude = -4.065818
        location.locationType = locationTypes["au"]
        location.note = "Room 0.15 is the main lecture theatre used for the conference. There are plug and USB charging sockets in the rows at the back of the room. Direct access to the room from the Physics Foyer involves stairs, but wheelchair lifts are available. A longer route outside the building can avoid stairs between the foyer and the lecture room."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "MP-0.15"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.aber.ac.uk/en/timetable/zones/penglais/physical-sciences/0.15/")
        location.webLink?.name = "Room Description"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "LL-A6"
        location.name = "Llandinam A6"
        location.shortName = "A6"
        location.active = true
        location.showImage = true
        location.frontListPosition = 20
        location.latitude = 52.416470
        location.longitude = -4.066544
        location.locationType = locationTypes["au"]
        location.note = "A6 is the a room used for the parallel sessions for parts of the conference. There aren't any power sockets in this room, but remember that you can charge your machine in the Physics Main Lecture Theatre."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "LL-A6"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.aber.ac.uk/en/timetable/zones/penglais/llandinam/a6/")
        location.webLink?.name = "Room Description"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "MP-foyer"
        location.name = "Physical Sciences Foyer"
        location.shortName = "Foyer"
        location.active = true
        location.showImage = true
        location.frontListPosition = 30
        location.latitude = 52.415938
        location.longitude = -4.065676
        location.locationType = locationTypes["au"]
        location.note = "Home of cake, biscuits, tea, coffee and a chance to chat. Registration takes place here."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "LL-B23"
        location.name = "Llandinam B23"
        location.shortName = "B23"
        location.active = true
        location.showImage = true
        location.frontListPosition = 40
        location.latitude = 52.416367
        location.longitude = -4.066299
        location.locationType = locationTypes["au"]
        location.note = "This room is used for one of the workshops. It is above A6 and across the car park from the Physical Sciences building.\n\nThere are plugs and USB charging sockets at each desk."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "LL-B23"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.aber.ac.uk/en/timetable/zones/penglais/llandinam/b23/")
        location.webLink?.name = "Room Description"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "AccommodationReception"
        location.name = "Accommodation Reception"
        location.shortName = "Accommodation Reception"
        location.active = true
        location.frontListPosition = 50
        location.latitude = 52.420920
        location.longitude = -4.059860
        location.locationType = locationTypes["au"]
        location.note = "Collect your university accommodation keys from here between 8:30 and 18:00. After 6pm, go to the Porters Lodge. Tell them if you are bringing a car onto campus. See the attendee information for details about car parking."
        
        locations[location.recordName!] = location
        
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Breakfast"
        location.name = "Breakfast (Ta Med Da)"
        location.shortName = "Breakfast"
        location.active = true
        location.showImage = true
        location.frontListPosition = 60
        location.latitude = 52.417670
        location.longitude = -4.064915
        location.locationType = locationTypes["au"]
        location.note = "Breakfast is available in Ta Med Da, which is in the Penbryn Hall of Residence near to the entrance of the University."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "medrus"
        location.name = "Medrus Mawr"
        location.shortName = "Medrus Mawr"
        location.active = true
        location.showImage = true
        location.frontListPosition = 70
        location.latitude = 52.417941
        location.longitude = -4.064823
        location.locationType = locationTypes["au"]
        location.note = "Medrus Mawr is a large conference room that we will use for the Conference Dinner event. This is above the place where you will get your breakfast (Ta Med Da). To enter, you can either go through this door and head to the back and up stairs. Alternatively, go to the right of this picture and follow the building around to another door. Go into the buildng and then up stairs to the first floor\n\nThere is a ramp and lift access to Medrus Mawr."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "medrus_mawr"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.aber.ac.uk/en/visitors/facilities/")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        
        
        
        ////////////////////////// Transport /////////////////////////////////////////////
        
        location = Location.createInstance(inContext: context)
        location.recordName = "vale_of_rheidol"
        location.name = "Vale of Rheidol Railway"
        location.shortName = "Vale of Rheidol"
        location.active = true
        location.showImage = true
        location.frontListPosition = 85
        location.latitude = 52.412524
        location.longitude = -4.080047
        location.locationType = locationTypes["transport"]
        location.note = "You can access the station from the side of the main railway station, just behind the taxi rank. If you are driving down to the station, you can use the postcode SY23 1PG to find the Vale of Rheidol car park."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "vale_of_rheidol"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.rheidolrailway.co.uk")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "RailwayStation"
        location.name = "Aberystwyth Railway Station"
        location.shortName = "Aberystwyth Railway Station"
        location.active = true
        location.showImage = true
        location.frontListPosition = 100
        location.latitude = 52.413816
        location.longitude = -4.081811
        location.locationType = locationTypes["transport"]
        location.note = "The Aberystwyth Railway station is in the centre of town. The main Taxi Rank is avilable outside and there is usually a lot of taxis available when trains are due."
        
        /*
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "RailwayStation"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "http://www.nationalrail.co.uk/stations_destinations/AYW.aspx")
        location.webLink?.name = "Station Information"
        */
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "TaxiRank"
        location.name = "Taxi Rank"
        location.shortName = "Taxis"
        location.active = true
        location.frontListPosition = 80
        location.latitude = 52.413906
        location.longitude = -4.082293
        location.locationType = locationTypes["transport"]
        location.note = "The main place to get a taxi is outside the railway station. Taxis are available for most of the day.\n\nIn the nighttime, taxis may also park near to the clock tower or near to KFC."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "PetrolTexaco"
        location.name = "Petrol Station: Texaco (town)"
        location.shortName = "Texaco"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.413497
        location.longitude = -4.083538
        location.locationType = locationTypes["transport"]
        location.note = "Petrol station in the centre of town, close to the railway station."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "PetrolTexaco"
        location.name = "Petrol Station: Texaco (edge of town)"
        location.shortName = "Texaco"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.407469
        location.longitude = -4.058695
        location.locationType = locationTypes["transport"]
        location.note = "Petrol station on the edge of town as you head on the A44 to mid-Wales."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "PetrolMorrisons"
        location.name = "Petrol Station: Morrisons"
        location.shortName = "Morrisons Petrol"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.405175
        location.longitude = -4.066559
        location.locationType = locationTypes["transport"]
        location.note = "Petrol station on the edge of town at the Morrisons supermarket."
        
        locations[location.recordName!] = location
        
        
        /////////////////////// Pubs //////////////////////////////////////////////////////////
        
        location = Location.createInstance(inContext: context)
        location.recordName = "rummers"
        location.name = "Rummers"
        location.shortName = "Rummers"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.411842
        location.longitude = -4.085372
        location.locationType = locationTypes["pubs"]
        location.note = "Close to the harbour, the pub has a beer garden. A steep-ish but flat path to access the beer garden. Steps to access the bar area. Live music on some nights."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "rummers"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.facebook.com/Rummers-Bar-825256554229183/")
        location.webLink?.name = "Facebook page"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "scholars"
        location.name = "Scholars"
        location.shortName = "Scholars"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.416676
        location.longitude = -4.081134
        location.locationType = locationTypes["pubs"]
        location.note = "Close to the bottom of the hill from the University to town. It runs a pub quiz on Sunday evenings, which you may like to try if you are arriving by Sunday."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "ship"
        location.name = "Ship and Castle"
        location.shortName = "Ship & Castle"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.413280
        location.longitude = -4.086769
        location.locationType = locationTypes["pubs"]
        location.note = "A few minutes walk from the Clock Tower at the top of the main high-street. The pub is known for its range of real ales."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "glengower"
        location.name = "Glengower Hotel"
        location.shortName = "Glengower"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.420357
        location.longitude = -4.084716
        location.locationType = locationTypes["pubs"]
        location.note = "On the sea front with views of Cardigan Bay. There is space to sit outside on a good day. Serves food. Close to the Cliff Railway."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "glengower"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://glengower.co.uk")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Academy"
        location.name = "The Academy"
        location.shortName = "The Academy"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.413929
        location.longitude = -4.086450
        location.locationType = locationTypes["pubs"]
        location.note = "At the top of Great Darkgate Street, which is the main street in the town centre. The pub is close to the Clock Tower and Starbucks."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "Academy"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "http://www.markettowntaverns.co.uk/pub-and-bar-finder/north-west/the-academy/")
        location.webLink?.name = "Further Information"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "wetherspoons"
        location.name = "Yr Hen Orsaf (Wetherspoons)"
        location.shortName = "Wetherspoons"
        location.active = true
        location.showImage = true
        location.frontListPosition = 90
        location.latitude = 52.414176
        location.longitude = -4.081810
        location.locationType = locationTypes["pubs"]
        location.note = "Located at the front of the railway station in the centre of town."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "yr_hen_orsaf"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.jdwetherspoon.com/pubs/all-pubs/wales/ceredigion/yr-hen-orsaf-aberystwyth")
        location.webLink?.name = "Pub Website"
        
        locations[location.recordName!] = location
        
        ////////////////// Supermarkets /////////////////////////////////////////////
        
        location = Location.createInstance(inContext: context)
        location.recordName = "CKFoodstores"
        location.name = "CK Foodstores"
        location.shortName = "CK Foodstores"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.418474
        location.longitude = -4.059800
        location.locationType = locationTypes["sm"]
        location.note = "Located at the top of the hill, behind the University campus. This is the closest supermarket to the University accommodation. Open from 7am to 10pm from Monday to Saturday and 10am to 4pm on Sunday."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "ck"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "http://www.cksupermarkets.co.uk")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Tesco"
        location.name = "Tesco"
        location.shortName = "Tesco"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.412533
        location.longitude = -4.082721
        location.locationType = locationTypes["sm"]
        location.note = "Located close to railway station. This is open from 6am to 10pm Monday to Saturday and 11am to 5pm on Sunday."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "tesco"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.tesco.com/store-locator/uk/?bid=4630")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Morrisons"
        location.name = "Morrisons"
        location.shortName = "Morrisons"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.404435
        location.longitude = -4.068203
        location.locationType = locationTypes["sm"]
        location.note = "Located on the edge of town as part of a retail park. Open 6am to 11pm Monday to Saturday and 10am to 4pm on Sunday."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "Morrisons"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://my.morrisons.com/storefinder/240")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Iceland"
        location.name = "Iceland"
        location.shortName = "Iceland"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.413032
        location.longitude = -4.079567
        location.locationType = locationTypes["sm"]
        location.note = "Located on the edge of town as part of a retail park, next door to Lidl. Open 8am to 8pm Monday to Saturday and 10am to 4pm on Sunday."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "Iceland"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "http://www.iceland.co.uk/store-finder/2835/aberystwyth")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Lidl"
        location.name = "Lidl"
        location.shortName = "Lidl"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.412903
        location.longitude = -4.079730
        location.locationType = locationTypes["sm"]
        location.note = "Located in small retail park close to the railway station, next door to Lidl. Open from 8am to 10pm Monday to Saturday and 10am to 4pm on Sunday."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "Lidl"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.lidl.co.uk/en/Store-Finder-4186.htm")
        location.webLink?.name = "Website Store Locator"
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "Spar24"
        location.name = "Spar 24 hour"
        location.shortName = "Spar 24 hour"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.415622
        location.longitude = -4.083386
        location.locationType = locationTypes["sm"]
        location.note = "Located in the centre of town, along the road from Barclays bank. Open 24 hours every day."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "SparCorner"
        location.name = "Spar"
        location.shortName = "Spar"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.416240
        location.longitude = -4.079813
        location.locationType = locationTypes["sm"]
        location.note = "Located on the corner as you reach the bottom of the hill from the University. Small convenience store, open until around 11pm."
        
        locations[location.recordName!] = location
        
        location = Location.createInstance(inContext: context)
        location.recordName = "PremierExpress"
        location.name = "Premier Express"
        location.shortName = "Premier Express"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.416023
        location.longitude = -4.080254
        location.locationType = locationTypes["sm"]
        location.note = "Located on the corner as you reach the bottom of the hill from the University. Small convenience store, open until around 11pm."
        
        locations[location.recordName!] = location
        
        
        ////////////////// Cafe /////////////////////////////////////////////
        /*
        location = Location.createInstance(inContext: context)
        location.recordName = "CoffeNo1"
        location.name = "Coffee #1"
        location.shortName = "Coffee #1"
        location.active = true
        location.frontListPosition = -1
        location.latitude = 52.416045
        location.longitude = -4.083626
        location.locationType = locationTypes["cafe"]
        location.note = "In the centre of town, along Terrace Road. At Barclays Bank, head towards the sea and you will find Coffee #1 on the right."
        
        location.webLink = WebLink.createInstance(inContext: context)
        location.webLink?.recordName = "CoffeeNo1"
        location.webLink?.active = true
        location.webLink?.url = URL(string: "https://www.coffee1.co.uk/locations/aberystwyth/")
        location.webLink?.name = "Website"
        
        locations[location.recordName!] = location
        
        
        https://www.starbucks.co.uk/store-locator/store/1009693/aberstwyth-darkgate-street-47-49-great-darkgate-street-ceredigion-wls-sy-23-1
        */
        
        return locations
    }
    
    private func initialiseWebLinks() -> Dictionary<String,WebLink> {
        var webLinks = Dictionary<String,WebLink>()
        
        var link = WebLink.createInstance(inContext: context)
        link.recordName = "cwrs_mynediad"
        link.name = "Cwrs Mynediad App"
        link.url = URL(string: "http://www.cwrsmynediad.com/")
        link.active = true
        webLinks[link.recordName!] = link
        
        link = WebLink.createInstance(inContext: context)
        link.recordName = "cwrs_sylfaen"
        link.name = "Cwrs Sylfaen App"
        link.url = URL(string: "http://www.cwrssylfaen.com/")
        link.active = true
        webLinks[link.recordName!] = link
        
        link = WebLink.createInstance(inContext: context)
        link.recordName = "iosdevuk"
        link.name = "iOSDevUK Website"
        link.url = URL(string: "http://www.iosdevuk.com/")
        link.active = true
        webLinks[link.recordName!] = link
        
        return webLinks
    }
    
    private func initialiseSpeakers(withWebLinks webLinks: Dictionary<String,WebLink>) -> Dictionary<String,Speaker> {
        
        var speakers = Dictionary<String,Speaker>()
        
        var speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "neil_taylor"
        speaker.name = "Neil Taylor"
        speaker.biography = "Neil is one of the conference helpers and wrote the app for the conference. He is a lecturer in the Department of Computer Science at Aberystwyth University, talking about mobile systems, web systems and agile development. Neil has taught iOS programming courses in Wales with Chris Price. He and Chris have also produced apps for Welsh learners."
        speaker.twitterId = "digidol"
        speaker.addToWebLinks(webLinks["cwrs_mynediad"]!)
        speaker.addToWebLinks(webLinks["cwrs_sylfaen"]!)
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "chris_price"
        speaker.name = "Chris Price"
        speaker.twitterId = "iosdevuk"
        speaker.biography = "Chris is the main conference oragniser. He is a Senior Lecturer in the Deparment of Computer Science at Aberystwyth University. His interest in iOS quickly led to running courses around Wales teaching iOS programming. He has produced several apps to help Welsh learners."
        speaker.addToWebLinks(webLinks["cwrs_mynediad"]!)
        speaker.addToWebLinks(webLinks["cwrs_sylfaen"]!)
        speaker.addToWebLinks(webLinks["iosdevuk"]!)
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "paul_hudson"
        speaker.name = "Paul Hudson"
        speaker.biography = "Paul is the author of Hacking with Swift, Pro Swift, Server-Side Swift, Hacking with macOS, Hacking with watchOS, Swift Coding Challenges, Practical iOS 11, and more. Suffice it to say, he quite likes Swift. And coffee. (But mostly Swift.) (And coffee.) "
        speaker.twitterId = "twostraws"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "you"
        speaker.name = "You"
        speaker.biography = "You. With your different skills and experience. You help make iOSDevUK what it is. As well as attending the sessions, come along to the pre and post-conference workshops and the socials. Some of you have also volunteered talks as part of two short talk sessions during the conference."
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "steve_scott"
        speaker.name = "Steve (Scotty) Scott"
        speaker.twitterId = "macdevnet"
        speaker.biography = "OS X / iOS Developer and host of The iDeveloper Podcast."
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "maxim_zaks"
        speaker.name = "Maxim Zaks"
        speaker.biography = "Tells computers how to waste electricity. Hopefully in efficient, or at least useful way."
        speaker.twitterId = "iceX33"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "christopher_batin"
        speaker.name = "Christopher Batin"
        speaker.biography = "Been doing iOS development for a few years but only commercially for 2 years. Left university a year ago straight into Sky Bet working on a web wrapper app. More recently started a position at EE working on the MyEE iOS app."
        speaker.twitterId = "cjbatin"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "ewa_bielska"
        speaker.name = "Ewa Bielska"
        speaker.biography = "I started working in Allegro as a manual mobile tester. Gradually I turned into iOS testing and got to know more about this specific platform. After some time I started automating UI tests and writing small features for iOS application and corresponding unit test. Right now I am continuously learning and improving my testing and coding skills. I am passionate about teaching kids basics of programming and sharing my experience during local meetups and conferences."
        speaker.twitterId = "ewabielskapoz"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "aleksander_grzyb"
        speaker.name = "Aleksander Grzyb"
        speaker.biography = "I've been a professional iOS developer for more than 2 years, but  I wrote my first app around 5 years ago. I learned iOS on my own while on a student exchange program in Spain. I chose iOS, because I was fascinated, and still am, with Apple products. I admire their values, such as, attention to detail and the goal of connecting art with technology. Over the last 2 years, I’ve learnt a lot about iOS development and want to share my experience that I think can be valuable to others and give something back to the community."
        speaker.twitterId = "aleksandergrzyb"
        speaker.linkedIn = "aleksandergrzyb"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "elliot_schrock"
        speaker.name = "Elliot Schrock"
        speaker.biography = "Elliot Schrock is an entrepreneur, recovering mathematician, Raspberry Pi enthusiast, and mobile app developer extraordinaire. He currently lives in NYC, where he runs a small mobile app development company, advises various entrepreneurship competitions and startups, and gazes out windows while holding a glass of scotch. He should really get out more often."
        speaker.twitterId = "elliot_schrock"
        speakers[speaker.recordName!] = speaker
        
        /*
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "oscar_antonio_duran_grillo"
        speaker.name = "Oscar Antonio Duran Grillo"
        speaker.biography = "I enjoy making apps, trying to learn a few things in the process, I'm a lazy person so I try to automate as much as possible of my work, love architecting apps from the ground using clean code, tdd, solid architectures. Always trying to make my code to follow S.O.L.I.D principles when possible, I really enjoy the data-driven approach and watching companies grow (love watching stats about the app/company). Always trying to improve as a developer and as a person. "
        speakers[speaker.recordName!] = speaker
        */
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "luca_bartoletti"
        speaker.name = "Luca Bartoletti"
        speaker.biography = "Currently I'm iOS lead at Citymapper. I started working on iOS in 2008. I worked in big companies and small startup before joining Citymapper in 2014."
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "gregg_jaskiewicz"
        speaker.name = "Gregg Jaskiewicz"
        speaker.biography = "Freelancer, Maker, Software engineer, Security Architect, iOS and macOS Developer. "
        speaker.twitterId = "greggjaskiewicz"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "francisco_reynolds"
        speaker.name = "Francisco Reynolds"
        speaker.biography = "Been writing iOS apps for +5 years, I'm from Buenos Aires, Argentina, currently works as Head of Tech @ CookUnity NY."
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "chris_winstanley"
        speaker.name = "Chris Winstanley"
        speaker.biography = "To be added"
        speaker.twitterId = "CWinstanley90"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "jayesh_kawli"
        speaker.name = "Jayesh Kawli"
        speaker.biography = "I am Jayesh Kawli, an iOS developer living in Boston, Massachusetts. I work for Wayfair as a Senior iOS developer. I am a part of checkout and shipping team which handles cart, payments, loyalty and gift cards in Wayfair application. Previously at Wayfair, I worked in Platforms team which handles core architecture, network and data layer and general performance optimization of the application. Besides working at Wayfair I like to work on side-projects and open source libraries. As an active user of open source libraries, I feel like it's my responsibility to give something back to the community. I also write a blog (https://jayeshkawli.ghost.io) which touches active topics in iOS development along with occasional off-topics such as food, travel and web development."
        speaker.twitterId = "JayeshKawli"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "phil_nash"
        speaker.name = "Phil Nash"
        speaker.biography = "Phil is the author of the test frameworks, Catch - for C++ and Objective-C, and Swordfish for Swift. As Developer Advocate at JetBrains he's involved with CLion, AppCode and ReSharper C++. More generally he's an advocate for good testing practices, TDD and using the type system and functional techniques to reduce complexity and increase correctness. He's previously worked in Finance and Mobile as well as an independent consultant and coach specialising in TDD on iOS."
        speaker.twitterId = "phil_nash"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "kateryna_gridina"
        speaker.name = "Kateryna Gridina"
        speaker.biography = "Kateryna is a mobile feature lead at Zalando."
        speaker.twitterId = "gridNAka"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "tim_condon"
        speaker.name = "Tim Condon"
        speaker.biography = "Vapor expert, founder of Broken Hands and BBC software engineer."
        speaker.twitterId = "0xTim"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "shashikant_jagtap"
        speaker.name = "Shashikant Jagtap"
        speaker.biography = "Shashikant is DevOps practitioner for Mobile apps especially iOS and other Apple platforms. He has automated release pipelines, implemented CI/CD solutions and enabled DevOps practices for iOS apps using native Apple Developer tools and open-source tools. Shashikant blogs about iOS DevOps and Continuous Delivery on his personal blog a.k.a XCBlog. His blogs also published on Medium and DZone."
        speaker.twitterId = "Shashikant86"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "mikhail_churbanov"
        speaker.name = "Mikhail Churbanov"
        speaker.biography = "Being in software development for about 10 years I've got wide experience and worked with many languages. But after acquaintance with Swift it totally became my favorite one and my primary focus. Last years I've dived into iOS development and also experimented with Apple ecosystem devices like iBeacons, Smart e-locks, Watches and TV."
        speaker.twitterId = "rinold_nn"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "adam_rush"
        speaker.name = "Adam Rush"
        speaker.biography = "Adam Rush is a contract iOS developer with over 7 years experience. He writes for raywenderlich.com and often speaks at conferences."
        speaker.twitterId = "adam9rush"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "rob_whitaker"
        speaker.name = "Rob Whitaker"
        speaker.biography = "iOS developer at CapitalOneUK. Watches wrestling, builds Lego, drinks beer, likes nerdy stuff."
        speaker.twitterId = "RobRWAPP"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "luke_parham"
        speaker.name = "Luke Parham"
        speaker.biography = "Luke is an iOS Developer at Fyusion where he works on architecture and performance for the Fyuse SDK, a platform for spatial photography. He's also a writer/video maker at RayWenderlich.com and an avid Rocket Leaguer."
        speaker.twitterId = "lukeparham"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "daniel_leivers"
        speaker.name = "Daniel Leivers"
        speaker.biography = "I've been an iOS developer since the launch of the App Store and have worked on apps with a variety of different clients including The Wall Street Journal, Audi, Cartoon Network and more. I am also one of the organisers of SWmobile (a mobile focused meet up group in the South West of the UK) https://www.meetup.com/swmobile/"
        speaker.twitterId = "sofaracing"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "joachim_kurz"
        speaker.name = "Joachim Kurz"
        speaker.biography = "Joachim is working as an iOS developer at Yelp and he likes to give talks about APIs and tools that are super-valuable in day-to-day live but are often overshadowed by discussions about the newest technologies or yet another architecture style. One of his favorite review-comments is \"there is a formatter for that\". He has seen many ways to do formatting badly and many unnecessary `stringWithFormat:` calls and is trying to fight them where possible."
        speaker.twitterId = "cocoafrog"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "manu_molina"
        speaker.name = "Manu Carrasco Molina"
        speaker.biography = "Started with my C64 at age 11 in 1987. Became a Pro Software Dev in 1997 after 3 years of CS. Started the first french podcast about Apple in 2005. Started developing for iOS in 2008. With Swift since 2014 (pre-1.0). Just started to work for Certgate, a company which Businesses is Security and Privacy."
        speaker.twitterId = "stuffmc"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "ellen_shapiro"
        speaker.name = "Ellen Shapiro"
        speaker.biography = "Ellen Shapiro is an iOS and Android developer for Bakken & Bæck's Amsterdam office. She's written and edited tutorials for RayWenderlich.com for the last 5 years, and this year co-authored her first book for their team, Kotlin Apprentice. She is working in her spare time to help bring songwriting app Hum to life. When she's not writing code, writing about code, or speaking about code, Ellen is usually biking around the Netherlands, traveling as much as she can get away with, playing sous-chef to her fiancée Lilia, or relentlessly Instagramming their cats."
        speaker.twitterId = "DesignatedNerd"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "dave_verwer"
        speaker.name = "Dave Verwer"
        speaker.biography = "Dave is a freelance/independent iOS developer and author of [iOS Dev Weekly](https://iosdevweekly.com). He has been developing for the Mac and iOS since 2006 and while he did take a brief diversion into email software with the formation, and then sale of [Curated](https://curated.co) he is now firmly focused back on iOS!"
        speaker.twitterId = "daveverwer"
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "chiara_chiappini"
        speaker.name = "Chiara Chiappini"
        speaker.biography = "Chiara is a Developer Advocate at Google in the Developer Relations team. She helps Google partners to be successful on the web, Android and iOS."
        speakers[speaker.recordName!] = speaker
        
        speaker = Speaker.createInstance(inContext: context)
        speaker.recordName = "peter_friese"
        speaker.name = "Peter Friese"
        speaker.biography = "Peter is a Developer Advocate at Google, where he spends his time building and improving APIs and talking to developers. In his spare time, he drinks tea - hot, with milk."
        speakers[speaker.recordName!] = speaker
        
        return speakers
    }
    
    private func initialiseSections(forDays days: Dictionary<String,Day>) -> Dictionary<String,Section> {
        
        var sections = Dictionary<String,Section>()
            
        var section = Section.createInstance(inContext: context)
        section.recordName = "d1_s1"
        section.name = "Monday Afternoon"
        days["2018-09-03"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d1_s2"
        section.name = "Monday Evening"
        days["2018-09-03"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d2_s1"
        section.name = "Tuesday Morning"
        days["2018-09-04"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d2_s2"
        section.name = "Tuesday Afternoon"
        days["2018-09-04"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d2_s3"
        section.name = "Tuesday Evening"
        days["2018-09-04"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d3_s1"
        section.name = "Wednesday Morning"
        days["2018-09-05"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d3_s2"
        section.name = "Wednesday Afternoon"
        days["2018-09-05"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d3_s3"
        section.name = "Wednesday Evening"
        section.footer = "Wednesday evening, delegates are free to sample the delights of Aberystwyth"
        days["2018-09-05"]?.addToSections(section)
        sections[section.recordName!] = section
    
        section = Section.createInstance(inContext: context)
        section.recordName = "d4_s1"
        section.name = "Thursday Morning"
        section.footer = "End of main conference"
        days["2018-09-06"]?.addToSections(section)
        sections[section.recordName!] = section
        
        section = Section.createInstance(inContext: context)
        section.recordName = "d4_s2"
        section.name = "Thursday Afternoon"
        section.header = "Optional workshops"
        days["2018-09-06"]?.addToSections(section)
        sections[section.recordName!] = section
        
        return sections
    }
    
    private func createSession(inSection section: Section, withRecordName recordName: String, startTime startDateTime: String, endTime endDateTime: String) -> Session {
        let session = Session.createInstance(inContext: context)
        session.recordName = recordName
        session.startTime = formatter.date(from: startDateTime) as NSDate?
        session.endTime = formatter.date(from: endDateTime) as NSDate?
        section.addToSessions(session)
        
        return session
    }
    
    private func initialiseSessionsAndSessionItemsOnDay1(forSections sections: Dictionary<String,Section>, withSpeakers speakers: Dictionary<String,Speaker>, locations: Dictionary<String,Location>) {
        
        //////////////////////////////////////////////////////////////////////////////////
        // Monday
        var session = createSession(inSection: sections["d1_s1"]!, withRecordName: "d1_s1_1",
                                    startTime: "2018-09-03T16:00:00+01:00", endTime: "2018-09-03T18:00:00+01:00")
        
        var sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "swift_bp"
        sessionItem.title = "Swift Best Practices"
        sessionItem.content = "Anyone can create a quick prototype, but how do you write code that will last? In this talk you'll learn how to design a smart, scalable application architecture that is easier to maintain, easier to test, and easier to understand."
        sessionItem.active = true
        sessionItem.type = SessionType.workshop
        sessionItem.addToSpeakers(speakers["paul_hudson"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d1_s2"]!, withRecordName: "d1_s2_1",
                                startTime: "2018-09-03T18:00:00+01:00", endTime: "2018-09-03T23:59:59+01:00")
        session.name = "After 6pm"
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "ws_social"
        sessionItem.title = "Optional Social"
        sessionItem.content = "There aren't any official activities on the Monday evening. There is an optional gathering at the Wetherspoons pub in the centre of town, at the front of the railway session. Come along at any point in the evening and see who else is there."
        sessionItem.active = true
        sessionItem.type = SessionType.social
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["wetherspoons"]
        session.addToSessionItems(sessionItem)
    }
    
    
    private func initialiseSessionsAndSessionItemsOnDay2(forSections sections: Dictionary<String,Section>, withSpeakers speakers: Dictionary<String,Speaker>, locations: Dictionary<String,Location>) {
        
        var session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_1",
                                    startTime: "2018-09-04T09:00:00+01:00", endTime: "2018-09-04T09:30:00+01:00")
        
        var sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "registration"
        sessionItem.title = "Registration"
        sessionItem.content = "Registration will take place in the foyer outside the main room for sessions. Come along and collect your badge. If you were at the workshop on Monday afternoon, you will already have your badge."
        sessionItem.active = true
        sessionItem.type = SessionType.registration
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_2",
                                startTime: "2018-09-04T09:30:00+01:00", endTime: "2018-09-04T09:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "welcome"
        sessionItem.title = "Welcome"
        sessionItem.content = "Hello! Welcome to iOSDevUK 2018. This short session will introduce the conference and provide any updates on the programme and arangements for the week."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["chris_price"]!)
        sessionItem.addToSpeakers(speakers["neil_taylor"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_3",
                                startTime: "2018-09-04T09:40:00+01:00", endTime: "2018-09-04T10:20:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "great_developer"
        sessionItem.title = "The Mark of a Great Developer"
        sessionItem.content = "Description to be added."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["steve_scott"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_4",
                                startTime: "2018-09-04T10:20:00+01:00", endTime: "2018-09-04T11:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "chatbot"
        sessionItem.title = "Making a Chat Bot"
        sessionItem.content = "In last 2 years I helped build 3 native iOS chat bots. One of them was listed in \"Best Apps on iPhone\" (AppStore Germany 2016). In this talk I will discuss the benefits of building a dedicated native app for a chat bot and techniques I used in different apps to create a chat experience."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["maxim_zaks"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_5",
                                startTime: "2018-09-04T11:00:00+01:00", endTime: "2018-09-04T11:30:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "tuesday_coffee_am"
        sessionItem.title = "Coffee Break"
        sessionItem.content = "Coffee and tea will be available in the foyer. Come and recharge and enjoy some cake."
        sessionItem.active = true
        sessionItem.type = SessionType.coffeeCake
        sessionItem.listOnFrontScreen = false
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_6",
                                startTime: "2018-09-04T11:30:00+01:00", endTime: "2018-09-04T12:10:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "storyboard"
        sessionItem.title = "Reasons we should all be using storyboard"
        sessionItem.content = "A high level look into why teams & individuals should look to use Interface Builder over programmatic layout where possible. We'll look into the advantages of Interface Builder and why these outweigh some of the major disadvantages. We'll also look into how as a team you can manage the risks associated with using Interface Builder and why you shouldn't be scared of them."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["christopher_batin"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "tests_at_scale"
        sessionItem.title = "Ogres, onions and layers - story about tests at scale"
        sessionItem.content = "We want to take you on the journey through different layers of tests in an iOS app that’s used by more than half million unique users per month. Get to know the way we test it, step by step, layer by layer. We start with advanced code static analysis, continue with mutation, snapshot and functional tests. We carry on with continuous delivery, A/B tests and usability tests. We want to share with you which tools we are using and what testing practices we believe in. This is a true story driven by problems we experience at work, presented from tester’s and developer’s perspective."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["ewa_bielska"]!)
        sessionItem.addToSpeakers(speakers["aleksander_grzyb"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_7",
                                startTime: "2018-09-04T12:10:00+01:00", endTime: "2018-09-04T12:50:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "ux_patterns"
        sessionItem.title = "Leveraging Common UX Patterns to Build More Apps, Faster"
        sessionItem.content = "In this talk we'll discuss how to use common UX patterns and clever architecture to build your own personalized suite of reusable components. Armed with these new components, we'll show how easy it is to build a wide variety of apps in a very short period of time."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["elliot_schrock"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "citymapper"
        sessionItem.title = "Evolving and Maintaining the Citymapper App"
        sessionItem.content = "Maintain and evolve \"old\" and big iOS apps is becoming a topic now that the iOS ecosystem is becoming more mature. At Citymapper we started working on our iOS app in 2010. The talk we'll cover the challenges and solution we used in the years to be able to scale and maintain our code base. Also how we copped with iOS releases and the introduction of Swift."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["luca_bartoletti"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s1"]!, withRecordName: "d2_s1_8",
                                startTime: "2018-09-04T12:50:00+01:00", endTime: "2018-09-04T14:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "tuesday_lunch"
        sessionItem.title = "Lunch"
        sessionItem.content = "Come to the foyer to select your free lunch of sandwiches and crisps. If you prefer, you can buy other food from  outlets around the campus; see more in the list of locations."
        sessionItem.active = true
        sessionItem.listOnFrontScreen = false
        sessionItem.type = SessionType.lunch
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        /////////////////////////////// Afternoon ///////////////////////////////////////////
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_1",
                                startTime: "2018-09-04T14:00:00+01:00", endTime: "2018-09-04T14:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "tbc_2"
        sessionItem.title = "To be confirmed"
        sessionItem.content = "To be confirmed."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        //sessionItem.addToSpeakers(speakers["luca_bartoletti"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "fsm_ftw"
        sessionItem.title = "Finite State Machines in Swift FTW"
        sessionItem.content = "In every developer’s life, there are different problems we have to tackle. Every developer has their own tool box, bag of tricks to pull the solutions out of. I would like to invite you on a journey introducing you to the world of Finite State Machines. In this talk I’ll show you my own approach to solving some categories of problems using FSMs, as well as introduce you to a simple FSM framework in Swift."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["gregg_jaskiewicz"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_2",
                                startTime: "2018-09-04T14:40:00+01:00", endTime: "2018-09-04T15:20:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "coreml_vision"
        sessionItem.title = "Embracing iOS Machine Learning, using CoreML and Vision"
        sessionItem.content = "This talk will have a small introduction on what machine learning is and what can you do with the new frameworks Apple has created for use. I will show the potential uses for this technology and show working examples of what you can do, for example show how image analysis works."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["francisco_reynolds"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "siri_shortcuts"
        sessionItem.title = "Siri Shortcuts"
        sessionItem.content = "Details to be added."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["chris_winstanley"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_3",
                                startTime: "2018-09-04T15:20:00+01:00", endTime: "2018-09-04T16:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "speech_recognition"
        sessionItem.title = "Speech Recognition in iOS apps"
        sessionItem.content = """
        The Speech Recognition API is part of the Speech framework and was made available to developers by Apple in iOS 10. This API is used by Siri to perform periodic tasks through speech recognition activities and to improve the overall user experience.
        
        Developers can use speech recognition in their application as a dictation tool which requires no typing and saves a lot of time. This offers convenience and easier access to application features through spoken commands and improves the user engagement and application experience. This is useful for people with certain disabilities or conditions to navigate around and use the app conveniently.  Example use cases for this API are live language translation and quick app actions through spoken words such as a keyword search and application navigation.
        
        In this talk, we will give an introduction to the Speech Recognition API, provide a few technical details on how to use it, explore its building blocks, and its considerations for user privacy. We will also see how we can best design an application with the Speech Recognition API for a great user experience while adhering to the standard guidelines.
        
        Attendees of this session will take away the following:
        
        1. Introduction to iOS Speech Recognition API
        2. How to use and integrate this API with any application
        3. How to handle and trigger speech recognition
        4. User interface and privacy considerations
        
        By the end of the session, I will present a demo of an English-Spanish translation app that I have created using the Speech Recognition API.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["jayesh_kawli"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "optional_not_a_failure"
        sessionItem.title = "Option(al) Is Not a Failure"
        sessionItem.content = """
        Swift introduced Optionals on day one, but some of us are still getting used to them. Used appropriately they can be very useful - but they can also be abused!
        
        Swift 1 didn't have a cohesive error handling strategy. Some of us experimented with something called the Result monad. Exceptions were introduced with Swift 2, but remain widely misunderstood. How do they fit in?
        
        Should you use Optionals for errors, or exceptions, or something else? Or not bother at all and rely on Bad Things never happening?
        
        How can we make sense of all this when, really, we just want to focus our efforts on getting everything to *work*, not worry about optimising for failures?
        
        This talk digs into what Swift really has to offer and shows it can all be much simpler than we're making out - and even fun!
        """
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["phil_nash"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_4",
                                startTime: "2018-09-04T16:00:00+01:00", endTime: "2018-09-04T16:30:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "tuesday_coffee_pm"
        sessionItem.title = "Coffee Break"
        sessionItem.content = "Coffee and tea will be available with biscuits. Come to the foyer to recharge."
        sessionItem.active = true
        sessionItem.type = SessionType.coffeeBiscuits
        sessionItem.listOnFrontScreen = false
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_5",
                                startTime: "2018-09-04T16:30:00+01:00", endTime: "2018-09-04T17:10:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "test_automation"
        sessionItem.title = "Tracking Test Automation"
        sessionItem.content = "Details to be added."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["kateryna_gridina"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d2_s2"]!, withRecordName: "d2_s2_6",
                                startTime: "2018-09-04T17:10:00+01:00", endTime: "2018-09-04T18:45:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "why_vapor"
        sessionItem.title = "Why Server-Side Swift and Vapor?"
        sessionItem.content = "Get an introduction to Vapor and Server-Side Swift. See how to create a fully featured CRUD application in 15 minutes and why you should choose server-side Swift."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["tim_condon"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        //////////////////////////////////// Evening /////////////////////////////////////////
        
        session = createSession(inSection: sections["d2_s3"]!, withRecordName: "d2_s3_1",
                                startTime: "2018-09-04T18:45:00+01:00", endTime: "2018-09-04T22:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "dinner"
        sessionItem.title = "Conference Dinner"
        sessionItem.content = """
        Come and join in the conference dinner in Medrus Mawr, near to the main entrance on campus. The meal is included as part of your conference fee. A great place to meet other attendees.
        
        The meal is sponsored by Compare The Market and the drinks are provided by Capital One.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.dinner
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["medrus"]
        session.addToSessionItems(sessionItem)
    }
    
        
    private func initialiseSessionsAndSessionItemsOnDay3(forSections sections: Dictionary<String,Section>, withSpeakers speakers: Dictionary<String,Speaker>, locations: Dictionary<String,Location>) {
        
        var session = createSession(inSection: sections["d3_s1"]!, withRecordName: "d3_s1_1",
                                    startTime: "2018-09-05T09:30:00+01:00", endTime: "2018-09-05T10:40:00+01:00")
        
        var sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "lightning_1"
        sessionItem.title = "Lightning Talks 1"
        sessionItem.content = "A series of short talks from conference attendees. We will soon be asking for volunteers to give one of the talks. There is a similar session on Thursday morning."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s1"]!, withRecordName: "d3_s1_2",
                                startTime: "2018-09-05T10:40:00+01:00", endTime: "2018-09-05T11:20:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "wednesday_coffee_am"
        sessionItem.title = "Coffee Break and Conference Photo"
        sessionItem.content = """
        ☕️ 🍰 📸
        
        Coffee. Tea. Cake. Come to the foyer for refreshments.
        
        We will also take the Conference Photo during the break. Arrangements for the photo will be announced just before the coffee break.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.coffeeCake
        sessionItem.listOnFrontScreen = false
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s1"]!, withRecordName: "d3_s1_3",
                                startTime: "2018-09-05T11:20:00+01:00", endTime: "2018-09-05T12:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "devops"
        sessionItem.title = "DevOps for iOS Apps"
        sessionItem.content = """
        DevOps and Continuous Delivery practices are becoming essential in the modern and competitive world of mobile app development. We are developing iOS apps for many years but couldn't bring best of DevOps and CI/CD into iOS development processes. There is huge potential in iOS tooling that we can go to fully automated builds and continuous *everything practices.
        
        This talk will explore strategies to adopt DevOps tools and practices in the iOS application development. We will touch the following topic in this talk: 1] How to apply 3 Pillars of DevOps to iOS app development. 2] Explore unique challenges of iOS Development that hinder CI/CD and DevOps practices and how to overcome them. 3] How to implement E2E build automation and CI/CD practices with help of native Apple Developer tools 4] Explore strategies tools to speed up iOS build, test and release process. 5] How Apple’s new AppStore Connect API will impact current build automation practice in future. At the end of this talk, you will be encouraged to setup CI/CD and DevOps practices or improve your existing practices to speed up the release process of iOS apps. You will learn various techniques and underlying Apple developer tools that can be used to automate an iOS build process.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["shashikant_jagtap"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "two_tales"
        sessionItem.title = "Two tales of one iOS project: symbiosis of design-first & server-side Swift"
        sessionItem.content = "Obviously most part of iOS apps need a backend and the accelerating server-side Swift express looks a promising option with many reasons advocating for it. But not to repeat them, I want to share the «the devil is in the details»-story of how the design-first approach using OpenAPI empowered with the Swift backend could help us mitigate different daily issues and benefit in efforts and overall experience of iOS development."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["mikhail_churbanov"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s1"]!, withRecordName: "d3_s1_4",
                                startTime: "2018-09-05T12:00:00+01:00", endTime: "2018-09-05T12:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "homekit"
        sessionItem.title = "A Deep Dive inside HomeKit"
        sessionItem.content = "It's time to give some love to HomeKit. Adam will be giving a detailed talk about HomeKit and how you can use it in your applications."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["adam_rush"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "testing_journey"
        sessionItem.title = "A Swift Testing Journey"
        sessionItem.content = "Details to be added."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["rob_whitaker"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s1"]!, withRecordName: "d3_s1_5",
                                startTime: "2018-09-05T12:40:00+01:00", endTime: "2018-09-05T14:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "wednesday_lunch"
        sessionItem.title = "Lunch"
        sessionItem.content = "Come to the foyer for your free lunch. If you prefer to have something other than sandwiches and crisps, you will find several places on campus to buy food."
        sessionItem.active = true
        sessionItem.listOnFrontScreen = false
        sessionItem.type = SessionType.lunch
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s2"]!, withRecordName: "d3_s2_1",
                                startTime: "2018-09-05T14:00:00+01:00", endTime: "2018-09-05T14:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "threads"
        sessionItem.title = "Threads through the Ages"
        sessionItem.content = " When you're writing an iOS app, you'll inevitably come upon work that would be better off happening in the background. With the advent of tools like GCD and NSOperations, it can be easy to use concurrency without really knowing much about what's going on under the hood. This can lead to bugs you don't quite understand and current code that isn't all that it could be. Come with me on this journey through the history of threads to see how they work and how you can harness their true potential."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["luke_parham"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "graph_ql"
        sessionItem.title = "An introduction to GraphQL"
        sessionItem.content = "An overview of GraphQL - what it is, why it's useful and what pitfalls you might encounter."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["daniel_leivers"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s2"]!, withRecordName: "d3_s2_2",
                                startTime: "2018-09-05T14:40:00+01:00", endTime: "2018-09-05T15:30:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "formatter"
        sessionItem.title = "There's a formatter for that"
        sessionItem.content = "We will take a look at all the Formatters Apple offers nowadays. We'll start with the well-known Date- and NumberFormatters and go through some of the more obscure ones like DateComponentsFormatter, ByteCountFormatter, MeasurementsFormatter, ISO8601DateFormatter and PersonNameComponentsFormatter. The general idea of the talk is to give an overview of all the formatters that exist, what they can and can't format and what their output looks like in different languages and locales to demonstrate why they are necessary. After that, attendees should know to think twice before using -[NSString stringWithFormat:] or Swift's string interpolation to generate user-visible strings because they know: There is already a formatter for that. And they also know that formatting logic is actually much more complicated than you naively assume and the result of using a formatter will be much better than trying to reinvent the wheel yourself."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["joachim_kurz"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s2"]!, withRecordName: "d3_s2_3",
                                startTime: "2018-09-05T15:30:00+01:00", endTime: "2018-09-05T16:10:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "privacy"
        sessionItem.title = "The importance of Privacy in iOS"
        sessionItem.content = "A lot of time Privacy of my data as a user is not a priority for Developers. Wether it's my calendar, my contacts, my location, I want as a user to be able to use an app without all of those attacks in my privacy. I want to talk about some of the things an iOS developer should do to ensure the most critical user can still use my app in some regards, and not just say \"I need all your information\" like on other platforms. This is the beauty of iOS, being able to fine grained (although not enough) so let's do this all together, as a beautiful community concerned by Privacy."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["manu_molina"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s2"]!, withRecordName: "d3_s2_4",
                                startTime: "2018-09-05T16:10:00+01:00", endTime: "2018-09-05T16:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "wednesday_coffee_pm"
        sessionItem.title = "Coffee"
        sessionItem.content = "Coffee and biscuits are available in the foyer."
        sessionItem.active = true
        sessionItem.listOnFrontScreen = false
        sessionItem.type = SessionType.coffeeBiscuits
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d3_s3"]!, withRecordName: "d3_s3_1",
                                startTime: "2018-09-05T17:30:00+01:00", endTime: "2018-09-06T09:30:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "train"
        sessionItem.title = "Free trip on steam train to Devils Bridge and back"
        sessionItem.content = """
        All attendees are invited to come on a free trip on a steam train to Devil's Bridge and back. You can find out more about the Vale of Rheidol railway at the link below. If you would like to come along, please be at the Vale of Rheidol station (next to the main railway station) by 5.15pm.
        
        The train will depart from Aberystwyth at 5.30pm. The carriages will be available for boarding from approximately 5.15pm.
        
        We should arrive at Devil's Bridge around 6.30pm. The train will return from Devil's Bridge at 7pm and should be back in Aberystwyth around 8pm.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.train
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["vale_of_rheidol"]
        session.addToSessionItems(sessionItem)
        
    }
    
    private func initialiseSessionsAndSessionItemsOnDay4(forSections sections: Dictionary<String,Section>, withSpeakers speakers: Dictionary<String,Speaker>, locations: Dictionary<String,Location>) {
        var session = createSession(inSection: sections["d4_s1"]!, withRecordName: "d4_s1_1",
                                    startTime: "2018-09-06T09:30:00+01:00", endTime: "2018-09-06T10:00:00+01:00")
        
        var sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "lightning_2"
        sessionItem.title = "Lightning Talks 2"
        sessionItem.content = "A series of short talks from conference attendees. We will soon be asking for volunteers to give one of the talks. There is a similar session on Wednesday morning."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s1"]!, withRecordName: "d4_s1_2",
                                startTime: "2018-09-06T10:00:00+01:00", endTime: "2018-09-06T10:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "project_management"
        sessionItem.title = "Product Management for Independent iOS Developers"
        sessionItem.content = "As an independent developer you probably don't have the luxury of a dedicated product manager, but that doesn't mean you can't benefit from product management techniques. Learn about market research and finding the \"jobs to be done\", getting useful user feedback, picking the right features to build and how to keep yourself on the right track to ship successful products and updates."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["dave_verwer"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s1"]!, withRecordName: "d4_s1_3",
                                startTime: "2018-09-06T10:40:00+01:00", endTime: "2018-09-06T11:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "thursday_coffee_am"
        sessionItem.title = "Coffee Break"
        sessionItem.content = "Coffee. Tea. Cake. Come to the foyer for refreshments."
        sessionItem.active = true
        sessionItem.type = SessionType.coffeeCake
        sessionItem.listOnFrontScreen = false
        sessionItem.addToSpeakers(speakers["you"]!)
        sessionItem.location = locations["MP-foyer"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s1"]!, withRecordName: "d4_s1_4",
                                startTime: "2018-09-06T11:00:00+01:00", endTime: "2018-09-06T11:40:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "all_the_f"
        sessionItem.title = "Properly Allocating the F**ks You Give"
        sessionItem.content = """
        📣 If you are offended by wildly improper language, you probably ought to have stopped reading after the talk title, but you should use this talk as an excuse to go get some proper coffee or tea whilst Ellen swears at everyone... and also not read the rest of this description. 📣

        We've all seen the memes of a person gleefully gesturing in the direction of the F**ks they don't give, and the self-help books about how to not give a F**k. But if what if the true challenge was not how not to give a F**k, but how to properly allocate the F**ks that you do give? Ellen will talk about her lifelong challenge with over-allocation of F**ks, the temptation to give zero F**ks whatsoever, and some thoughts and techniques she's been using to try and balance what F**ks to give.
        """
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["ellen_shapiro"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s1"]!, withRecordName: "d4_s1_5",
                                startTime: "2018-09-06T11:40:00+01:00", endTime: "2018-09-06T13:00:00+01:00")
        
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "star_swift"
        sessionItem.title = "What Star Wars can teach us about Swift"
        sessionItem.content = "Jedi, Sith, Death Stars, and X-Wings are images that have captured our imaginations since Star Wars was first released in 1977, but the lessons of fighting the good fight, mentoring those around you, and resisting the dark side are surprisingly applicable to Swift development – just without the Ewoks. (Maybe)."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["paul_hudson"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s2"]!, withRecordName: "d4_s2_1",
                                startTime: "2018-09-06T13:00:00+01:00", endTime: "2018-09-06T15:00:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "starting_vapor"
        sessionItem.title = "Getting started with Vapor and Server-Side Swift"
        sessionItem.content = "Get started with Vapor and Server-Side Swift! Enjoy a crash course into using Vapor and learn how to write REST APIs and interact with models in the database."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["tim_condon"]!)
        sessionItem.location = locations["MP-0.15"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "applying_arkit"
        sessionItem.title = "Applying ARKit"
        sessionItem.content = "In this ARKit workshop, I lead you from the basics till more advanced stuff related to AR in iOS apps. This workshop is a good way to dig into the augmented world if you are an absolute beginner. Join and have fun."
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["kateryna_gridina"]!)
        sessionItem.location = locations["LL-A6"]
        session.addToSessionItems(sessionItem)
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "firestore_1"
        sessionItem.title = "Cloud Firestore for iOS Apps"
        sessionItem.content = "Detail to be added"
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["chiara_chiappini"]!)
        sessionItem.addToSpeakers(speakers["peter_friese"]!)
        sessionItem.location = locations["LL-B23"]
        session.addToSessionItems(sessionItem)
        
        session = createSession(inSection: sections["d4_s2"]!, withRecordName: "d4_s2_2",
                                startTime: "2018-09-06T15:00:00+01:00", endTime: "2018-09-06T16:30:00+01:00")
        
        sessionItem = SessionItem.createInstance(inContext: context)
        sessionItem.recordName = "firestore_2"
        sessionItem.title = "Cloud Firestore for iOS Apps (continued)"
        sessionItem.content = "Detail to be added"
        sessionItem.active = true
        sessionItem.type = SessionType.talk
        sessionItem.addToSpeakers(speakers["chiara_chiappini"]!)
        sessionItem.addToSpeakers(speakers["peter_friese"]!)
        sessionItem.location = locations["LL-B23"]
        session.addToSessionItems(sessionItem)
        
    }
    
    private func batchDelete(entity: String) {
        do {
            let batchRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: entity))
            batchRequest.resultType = .resultTypeObjectIDs
            let batchResult = try context.execute(batchRequest) as! NSBatchDeleteResult
            if let objectIDs = batchResult.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    print("Object ID: \(objectID)")
                }
            }
            else {
                print("unable to process ids")
            }
            
        }
        catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
    }
    
    /**
     Removes all entities from the data store using batch delete operations. See
     `batchDelete` for further information.
     */
    func clearAllData() {
        batchDelete(entity: "Sponsor")
        batchDelete(entity: "AppSetting")
        
        batchDelete(entity: "WebLink")
        
        batchDelete(entity: "Speaker")
        
        batchDelete(entity: "Location")
        batchDelete(entity: "LocationType")
        
        batchDelete(entity: "SessionItem")
        batchDelete(entity: "Session")
        
        batchDelete(entity: "Section")
        batchDelete(entity: "Day")
    }
    
    /**
    
     */
    func updateDatastore(forIdentifier identifier: Int) {
        
        if identifier == 20180823 {
            updateOne(withIdentifier: identifier)
        }
        else if identifier == 20180831 {
            updateTwo(withIdentifier: identifier)
        }
        else {
            print("Unrecognised identifier")
        }
    }
    
    /**
     Applys a set of changes to the data stored locally. This represents the first update,
     available about a week after the app was first released.
     
     - Parameter identifier: The number used to represent this update.
     */
    private func updateOne(withIdentifier identifier: Int) {
        
        var values: [String:Any?] = [:]
        values = ["title": "Product Management for Independent iOS Developers"]
        if SessionItem.update(forRecordName: "project_management", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["biography":"Chris is a Software Engineer working on the BBC Sounds iOS application. In his spare time he develops TramTimes a transport app for Manchester. He also runs NSManchester a meetup for iOS developers in Manchester."]
        if Speaker.update(forRecordName: "chris_winstanley", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("False!")
        }
        
        values = ["content":"""
        Last year my team faced an interesting and challenging task - to unify, improve, make fully testable and sustainable tracking system for the whole app. To say there is not a lot of information about it - is to say nothing.
            
        I've visited a lot of different conferences, and listen to the many interesting and really cool topics. React Native, Unit testing, Architecture, How to.., Swift migration etc. But, unfortunately, have never heard a word about tracking and how other companies are doing it in their apps. I find this topic as a very important and complex one. How to cover your app with a tracking and not to pollute a code? How to test it properly? How to make it as much automated as possible?
            
        In my talk, I would like to cover all the crucial points of this topic and would like to share a live experience on how did we implement it in our application.
            
        Structure:
            What is tracking and why we should use it?
            Tracking use-cases
            Tracking tools
            How do we do it in Zalando?
            Challenges and best practices
        """]
        if SessionItem.update(forRecordName: "test_automation", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["content":"""
        I will be talking about the 'testing journey' we've had this year at Capital One - switching to Swift in the app.

        I'll cover the lessons Capital One has learned from unit testing in Swift. This includes manual mocks with protocols and expectation setting, moving to XCUI for UI testing and talking about some of the decisions we've made and why.
        """]
        if SessionItem.update(forRecordName: "testing_journey", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["content":"""
            Every year we give Scotty a title to talk about.
            
            He takes it as a challenge and delivers something great. However, he may not know what that is until a few hours before his talk. Be there for a fun and inspirational start to the conference.
            """]
        if SessionItem.update(forRecordName: "great_developer", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["content": "This 3 hour workshop on using Cloud Firestore (Firebase's brand new NoSQL database in the cloud) will cover a bunch of fairly useful topics -- what NoSQL databases are and how to structure your data, dealing with things like real-time listeners, transactions, keeping your data consistent, running cloud functions (for server-side logic), securing your data, and supporting offline mode."]
        if SessionItem.update(forRecordName: "firestore_1", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["content": """
            This is a continuation of the Cloud Firestore workshop. The description for the session is below.
            
            This 3 hour workshop on using Cloud Firestore (Firebase's brand new NoSQL database in the cloud) will cover a bunch of fairly useful topics -- what NoSQL databases are and how to structure your data, dealing with things like real-time listeners, transactions, keeping your data consistent, running cloud functions (for server-side logic), securing your data, and supporting offline mode.
            """]
        if SessionItem.update(forRecordName: "firestore_2", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["title":"How & Why to use storyboards within teams"]
        if SessionItem.update(forRecordName: "storyboard", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/London")
        
        values = ["endTime" : dateFormatter.date(from: "2018-09-03T23:59:59+01:00")! as NSDate]
        if Session.update(forRecordName: "d1_s2_1", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        
        values = ["intValue": identifier, "note":"First update"]
        if AppSetting.update(forRecordName: "data-model-version", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
    }
    
    /**
     Applys a set of changes to the data stored locally. This represents the second update,
     available shortly before the conference.
     
     - Parameter identifier: The number used to represent this update.
     */
    private func updateTwo(withIdentifier identifier: Int) {
        
        var values: [String:Any?] = [:]
        
        values = ["content": """
            A series of short talks on the following topics.
            
            Steve Westgarth - Flying Solo
            
            Jon Bell - AR at Bryn Celli Ddu
            
            Jan Kaltoun - Porting to MacOS with Marzipan
            
            Chris Greening - Building Effective Teams
            
            John Buckley - Using Promise  for improved async
            
            Magnus Holm - Custom Tableviews
            
            Mukund Agarwal - Ninja
            
            Amit Shabtay - Closing the Managerial Gap
            
            Neil Taylor - iOSDevUK.openSource()
            
            Peter Friese - Using Cloud Firestore with your app
            """]
        if SessionItem.update(forRecordName: "lightning_1", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["content": """
            A series of short talks on the following topics.
            
            John Gilbey - Can Good Code Save the World?
            
            Matt Gallagher - Internal Apps can be beautiful too
            
            Neil Morton - I want more downloads
            
            Oliver Foggin - Generic Collection Views
            
            Rodhan Hickey - The Reality of Augmented Reality
            """]
        if SessionItem.update(forRecordName: "lightning_2", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/London")
        
        values = ["endTime" : dateFormatter.date(from: "2018-09-04T17:50:00+01:00")! as NSDate]
        if Session.update(forRecordName: "d2_s2_6", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["endTime" : dateFormatter.date(from: "2018-09-05T20:00:00+01:00")! as NSDate]
        if Session.update(forRecordName: "d3_s3_1", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["endTime" : dateFormatter.date(from: "2018-09-06T12:30:00+01:00")! as NSDate]
        if Session.update(forRecordName: "d4_s1_5", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        if let section = Section.find(recordName: "d3_s3", inContext: context) {
           
            let session = createSession(inSection: section, withRecordName: "d3_s3_2", startTime: "2018-09-05T18:00:00+01:00", endTime: "2018-09-05T23:59:59+01:00")
            
            let sessionItem = SessionItem.createInstance(inContext: context)
            sessionItem.recordName = "afterparty"
            sessionItem.title = "Afterparty - Sponsor Event"
            sessionItem.content = "The Distance, one of our Gold sponsors, will be holding an afterparty at The Academy, Aberystwyth from 6pm to closing on Wednesday evening, with a free pint if you collect a token from their stand during the day. Also, keep an eye out for their competition as they'll be giving away an iPad to the winner at the afterparty."
            sessionItem.active = true
            sessionItem.type = SessionType.talk
            if let speaker = Speaker.find(recordName: "you", inContext: context) {
                sessionItem.addToSpeakers(speaker)
            }
            if let location = Location.find(recordName: "Academy", inContext: context) {
                sessionItem.location = location
            }
            
            session.addToSessionItems(sessionItem)
            
            print("Success")
        }
        else {
            print("Failure")
        }
        
        
        let speaker = Speaker.createInstance(inContext: context)
        speaker.name = "Adam Modzelewski"
        speaker.biography = "Adam is an iOS platform engineer at Starling Bank."
        speaker.recordName = "adam_modzelewski"
        
        values = [
            "content": "He will talk  about how they are enabling text updates without the need to recompile and issue an updated version via the app store, thus saving much time whilst empowering the wider team to make alterations.",
             "title": "Efficient localisation",
             "recordName": "localisation",
             "session": Session.find(recordName: "d2_s1_7", inContext: context),
             "location": Location.find(recordName: "MP-0.15", inContext: context),
             "speakers": [speaker]
        ]
        if SessionItem.update(forRecordName: "tbc_2", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        // Move session for Elliot Schrock
        values = [
            "session": Session.find(recordName: "d2_s2_1", inContext: context)
        ]
        if SessionItem.update(forRecordName: "ux_patterns", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        // Move workshop for Kateryna Gridina
        values = [
            "session": Session.find(recordName: "d1_s1_1", inContext: context)
        ]
        if SessionItem.update(forRecordName: "applying_arkit", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        let sponsor = Sponsor.createInstance(inContext: context)
        sponsor.recordName = "distance"
        sponsor.name = "The Distance"
        sponsor.tagline = "Leading UK Mobile App Development Company"
        sponsor.sponsorOrder = 40
        sponsor.url = URL(string: "https://thedistance.co.uk")
        sponsor.active = true
        sponsor.sponsorCategory = "Gold"
        sponsor.cellType = "imageTop"
        sponsor.note = "Stand at the conference and afterparty on Wednesday evening."
        
        let fireStoreLocation = Location.find(recordName: "LL-A6", inContext: context)
        values = [
            "location": fireStoreLocation
        ]
        if SessionItem.update(forRecordName: "firestore_1", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        if SessionItem.update(forRecordName: "firestore_2", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
        
        values = ["intValue": identifier, "note":"Second update"]
        if AppSetting.update(forRecordName: "data-model-version", inContext: context, withValues: values) {
            print("Success!")
        }
        else {
            print("Failure!")
        }
    }
    
}
