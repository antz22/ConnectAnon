<br />

<p align="middle">
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/logo.svg" width="20%">
</p>

<br />

<p align="middle">
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/logo_text.svg" width="80%">
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

- firebase plan - put in credit card (this is only a dev project so it should be fine)

- push notifications -- connecting with currently active user
- firebase admin - notifications and chat buddy functionality and getting reported
- connecting with chat buddies - should they be able to connect to the same person twice? or else they might get the same person as a converstaion they're already, ew buggy
- should chat buddies be able to do the same thing? then what about erasing things in the database, updating chattedwith?
- SHOULD THE CONVERSATIONS BE DISAPPEARING?
- change package names
- profile pics in chat rooms
- bans
- peer preferences?
- unsplash API production - how to download stuff?

- billion null errors
- clean up and abstract!
- animations
- firebase production
- error checking and null checking lol
- invitations for chat rooms?
- chat room creation applications
- ban applications


- new branch: implement newest message, how long ago it was (keep it on a separate branch, keep it low priority)

- figure out sign in through google or through email
- viewing time
- error handling on google sign in

- error text

- how to show most recent message, how long ago it was?
- add an if check sayign that if users is over like 50 then dont check thorugh each one?

# Potential Features

If we had enough money...

- change profile pictures
- change username

- show most recent message
- mark as unread / read

## Notes

- SystemUIOverlayStyle thing helps with android statusbar transparency
- IndexedStack and Mixin thing helps wiht not rebuilding the futurebuilder with bottomnavigation

## Resources

- [Google Sign In](https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24edn)

## Screenshots

<p align="middle">
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/landing.png" width="40%">
    &nbsp;&nbsp;&nbsp;
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/conversations.png" width="40%">
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/new_chat.png" width="40%">
    &nbsp;&nbsp;&nbsp;
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/chat.png" width="41%">
    <img src="https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/chat_rooms.png" width="40%">
</p>