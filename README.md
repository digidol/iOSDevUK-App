# iOSDevUK-App
Initial share of the iOSDevUK Conference App code. 

More notes to be added...

# Data Model

## Data Model Classes

### Day
A day is used to group items in the schedule. Whilst the day can be determined by checking the start and end dates for the sessions, it was decided to create an object graph to remove the need to perform those queries. 

### Section
A section is a group of sessions. For example, a section represents Tuesday afternoon. Within a section, there are sessions. 

### Session 
A session is a time block where something is happening in the conference. This has a start time and an end time. A session can have one or more session items.

### SessionItem 
The session item represents an entry that is shown on the schedule. It can have different types, e.g. talk or workshop.

### Setting 
This class holds a setting that is used by the application. 

## CoreData 

CoreData is used to store the data locally in the application. 


