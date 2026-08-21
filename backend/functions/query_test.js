const admin = require('firebase-admin');
admin.initializeApp({
  projectId: "shubhaytanam-buildtech-pvt-ltd"
});
const db = admin.firestore();
db.collection("offers").get().then(snap => {
  snap.forEach(doc => {
    console.log(doc.id, "=>", doc.data().title.en, "| status:", doc.data().status, "| active:", doc.data().active);
  });
}).catch(console.error);
