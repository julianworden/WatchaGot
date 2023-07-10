# Watcha Got?
Watcha Got is an inventory tracking iOS app built with UIKit, Core NFC and a custom backend made with Vapor and Heroku. It allows the user to receive, ship, and track inventory data with the help of physical NFC tags attached to inventory items.  

<p align="center">
    <img src="https://github.com/julianworden/WatchaGot/blob/main/READMEImages/Render.gif" width=30% height=30%>
</p>

## On The Surface

Watcha Got? is designed to be used by users who handle physical products in a store, and thus could benefit from an easy way to store and access data associated with those products.

To add an item to Watcha Got?, the user can tap the Receive Item button in the first view. After entering the item's information in the subsequent view, the user will be prompted to optionally transmit the item's data to an NFC tag. Regardless of whether or not the user uses an NFC tag, the data will be added to the Vapor database the app is connected to. 

If the user opted to scan the item's data to an NFC tag, they will be prompted to erase it from that tag before tapping the Ship Item button in ItemDetailsViewController. Once they've scanned the tag that corresponds to the item in question, the item will be erased from the tag and the database. If the item's data has not been transmitted to an NFC tag, then shipping the item will simply delete it from the database. An item's data can also be transmitted to an NFC tag after the item's initial creation via the Add Tag button in ItemDetailsViewController.

Lastly, Watcha Got? features full support for both Light and Dark Mode, Dynamic Type, and VoiceOver.

## Under the Hood
Watcha Got? was built with:

- Swift and UIKit
- Combine
- Core NFC
- Heroku
- Vapor

For testing the Vapor server locally, the following technologies were also used:

- Azure Data Studio
- Docker
- ngrok
- Postman

## Notes

- At this time, Watcha Got? does not feature user accounts. This will be added in a future update to leverage Vapor's user authentication features.
