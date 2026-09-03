// Add missing 'id' field to existing map entries in referredUserIds

const { initializeApp } = require('firebase/app');
const { getFirestore, doc, getDoc, updateDoc } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: 'AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8',
  appId: '1:806384462409:web:de2e73aa69df8d39362d98',
  projectId: 'shubhaytanam-buildtech-pvt-ltd',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const TARGET_UID = 'QLzLAcUAdwPHQKqf9Ld5V5puur33';

function newId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return Array.from({ length: 20 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

async function run() {
  const ref = doc(db, 'users', TARGET_UID);
  const snap = await getDoc(ref);
  if (!snap.exists()) { console.error('User not found'); process.exit(1); }

  const existing = snap.data().referredUserIds ?? [];
  console.log('Before:', JSON.stringify(existing, null, 2));

  const needsId = existing.some(e => typeof e === 'object' && !e.id);
  if (!needsId) {
    console.log('All entries already have id field. Nothing to do.');
    process.exit(0);
  }

  const updated = existing.map(e => {
    if (typeof e === 'string') {
      return { id: newId(), customerId: e, createdAt: null };
    }
    if (typeof e === 'object' && !e.id) {
      return { id: newId(), ...e };
    }
    return e;
  });

  await updateDoc(ref, { referredUserIds: updated });
  console.log('\nAfter update:');
  updated.forEach(e => console.log('  id=' + e.id + '  customerId=' + e.customerId));
  console.log('Done!');
  process.exit(0);
}

run().catch(err => { console.error('Error:', err.message); process.exit(1); });
