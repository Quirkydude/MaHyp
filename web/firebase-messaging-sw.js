importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB7PCevQJm5P06QKTN5ywiRf9HMt2nxQk8",
  authDomain: "cashzone-7dd34.firebaseapp.com",
  projectId: "cashzone-7dd34",
  storageBucket: "cashzone-7dd34.firebasestorage.app",
  messagingSenderId: "820250335949",
  appId: "1:820250335949:web:3a458f99ec6aeda3402784"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
