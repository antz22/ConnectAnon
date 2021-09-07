<br />

<p align="middle">
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/logo.svg" width="20%">
</p>

<br />

<p align="middle">
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/logo_text.svg" width="80%">
</p>

<p align="middle">
    Connect to peers anonymously. Chat with random classmates to make new friends and have spicy conversations. Find company to talk about sensitive personal experiences. ConnectAnon is an anonymous chatting app that lets users from the same school chat with each other about sensitive topics.
</p>

<br />

## Inspiration

There are many high schoolers who suffer from depression, loneliness or anxiety as a result of a huge number of factors that affect a high schooler’s period of adolescence. These can include academic competition, poor mindsets towards addiction, difficult circumstances at home, not being accepted at school, and more. 

If a student does not have a friend or an adult that they trust to confide in more personal matters, it can become a huge problem for their mental health and is detrimental to their well-being.

A solution to this problem could be to create an anonymous chatting app, specifically tailored towards peers in a specific school (at Montgomery, only Montgomery students can participate). Peers would then be able to seek advice, be heard, or make friends with other peers while hiding their identity in sharing sensitive topics.

This could help people dealing with depression to reach out to other peers in a more convenient manner (there is sometimes a stigma surrounding somebody reaching out for help), or students dealing with problems like drug addiction to reach out for help when doing so without their identity hidden would result in other problems.

Ultimately, this is an app that would make it easier for high school students to reach out to each other for help, and could help a lot of students in improving mental health.

## Tools

This app was created using the Flutter framework developed by Google, using the language Dart. Firebase was used for the backend services.

## TODO

### Priority
- unsplash API production - how to download stuff?
- display name ? keeping anonymity? any contracts or agreements to make?
- figure out sign in through google or through email
    landing page...
- play store production
- apple testing
- firebase production
    Hosting
    Security rules
    Firestore
    App store
    Testing
    Android Play Store
    Apple App Store
- releasing the code? (any sensitive information?) // open source it? (market it, reddit it, etc)
- notify when history reset
- maybe make this instead just throw an error and not make the conversation - users should archive convos anyway.

### Important

- admin notifications - chat room creation, reports, chat buddies
- firebase plan - put in credit card (this is only a dev project so it should be fine)
- manual review
    Reports
    Chat Room creation requests
- comment and delete comments
- create an admin account? see (users?), ban? users, see and accept or reject chat room requests, see and review reports, add chat buddies, etc



### Minor

- keyboard slow animation
- volunteer request page - grade, gender, username, whether or not they've been talked to before
- null errors!!
- notify when history is being refreshed?


### Future / Potential

- dark mode...
- upon joining, joining general chat room and volunteer support if volunteer
- chat preview name purple if chat buddy
- change 'chat buddy name'
- think about other schools

- should chat buddies be able to do the same thing? then what about erasing things in the database, updating chattedwith?
- peer preferences?

- add an if check sayign that if users is over like 50 then dont check thorugh each one?

### Problems
- there will probably be duplicate conversations somewhere, a person will get someone they've already talked to.
- volunteers might get duplicate requests. will rarely happen though, hopefully.
- messages (chat room messages and messages) can't be programmatically.

# Questions

- SHOULD THE CONVERSATIONS BE DISAPPEARING? -> no, just use archive as 'end live chat' button

- what if someone requests the same chat buddy multiple times?
    just be ware of duplicate requests, delete the other one. it should rarely happen

- ANIMATIONS
  - these will step up your app to be potentially usable.
  - don't think it's gonna work. frontend and backend are completely separated.

- streambuilders instead of futurebuilders
    simply added more fields to the Group and ChatRooms collections so you wouldn't have to query the user doc each time
    also sorts it based on last timestamp
    doesn't have to query the group separately on the preview components

- when userIds is empty / the user has already talked to all the peers or all the volunteers
    their history will be reset, so in the future they might get duplicate conversations.
    COULD make a 'currentlyChattingWith' field to account for convos not archived, but not right now.

# Potential Features

If we had enough money...

- change profile pictures
- change username

- show most recent message
- mark as unread / read

## Notes

- SystemUIOverlayStyle thing helps with android statusbar transparency
- IndexedStack and Mixin thing helps wiht not rebuilding the futurebuilder with bottomnavigation
- Provider.of(context) without the listen: false will not work.
- Performance optimizations:
    always dispose your controllers (both animation controllers and text editing controllers) (and other ones too)
    use const for EdgeInsets and SizedBoxes -- they won't be rebuilt
- fieldvalue.arrayUnion only does unique values lol

## Resources

- [Google Sign In](https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24edn)
- [Changing Project name](https://github.com/flutter/flutter/issues/35976)

## Screenshots

<p align="middle">
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/landing.png" width="40%">
    &nbsp;&nbsp;&nbsp;
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/conversations.png" width="40%">
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/new_chat.png" width="40%">
    &nbsp;&nbsp;&nbsp;
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/chat.png" width="41%">
    <img src="https://github.com/antz22/ConnectAnon/blob/master/screenshots/chat_rooms.png" width="40%">
</p>
