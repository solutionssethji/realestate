const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'shubhaytanam-buildtech-pvt-ltd' });
const db = admin.firestore();
db.collection('adminNotifications').orderBy('createdAt', 'desc').limit(5).get().then(snapshot => {
  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(`ID: ${doc.id}, type: ${typeof data.createdAt}, value: ${data.createdAt}`);
  });
}).catch(console.error);
