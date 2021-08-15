const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('Messages/{groupChatId}/messages/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.idFrom
    const idTo = doc.idTo
    const messageContent = doc.content

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('Users')
      .where('id', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().alias}`)
        //   if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
          if (userTo.data().pushToken) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('Users')
              .where('id', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().alias}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${userFrom.data().alias}"`,
                      body: messageContent,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })
    return null
  })