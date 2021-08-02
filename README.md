# anonymous_chat

ConnectAnon is an anonymous chatting app that lets users from the same school chat with each other about sensitive topics.

## Inspiration

There are many high schoolers who suffer from depression, loneliness or anxiety as a result of a huge number of factors that affect a high schooler’s period of adolescence. These can include academic competition, poor mindsets towards addiction, difficult circumstances at home, not being accepted at school, and more. 

If a student does not have a friend or an adult that they trust to confide in more personal matters, it can become a huge problem for their mental health and is detrimental to their well-being.

A solution to this problem could be to create an anonymous chatting app, specifically tailored towards peers in a specific school (at Montgomery, only Montgomery students can participate). Peers would then be able to seek advice, be heard, or make friends with other peers while hiding their identity in sharing sensitive topics.

This could help people dealing with depression to reach out to other peers in a more convenient manner (there is sometimes a stigma surrounding somebody reaching out for help), or students dealing with problems like drug addiction to reach out for help when doing so without their identity hidden would result in other problems.

Ultimately, this is an app that would make it easier for high school students to reach out to each other for help, and could help a lot of students in improving mental health.

## Tools

This app was created using the Flutter framework developed by Google, using the language Dart. Firebase was used for the backend services.

## TODO

- add profile picture functionalities
- make user setup part better
- figure out sign in through google or through email
- redesign new pages
- prettify readme

- error text
- bans
- push notifications -- how to connect them with a currently active user?

- make sure time shows on right side for other persons messages
- how to show most recent message, how long ago it was?
- choose preferences for the user
- add an if check sayign that if users is over like 50 then dont check thorugh each one?

## Notes

- SystemUIOverlayStyle thing helps with android statusbar transparency
- IndexedStack and Mixin thing helps wiht not rebuilding the futurebuilder with bottomnavigation

## Resources

- [Google Sign In](https://medium.com/flutter-community/flutter-implementing-google-sign-in-71888bca24edn)

## Screenshots

![Landing](https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/landing.png)

![Conversations](https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/conversations.png)

![New Chat](https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/new_chat.png)

![Chat](https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/chat.png)

![Chat Rooms](https://github.com/antz22/AnonymousChatApp/blob/master/screenshots/chat_rooms.png)
