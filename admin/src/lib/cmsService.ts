import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from './firebase';

export async function getSetting(settingName: string) {
  try {
    const docRef = doc(db, 'setting', settingName);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return docSnap.data();
    }
    return null;
  } catch (error) {
    console.error(`Error fetching setting/${settingName}:`, error);
    return null;
  }
}

export async function saveSetting(settingName: string, data: any) {
  try {
    const docRef = doc(db, 'setting', settingName);
    await setDoc(docRef, data, { merge: true });
    return true;
  } catch (error) {
    console.error(`Error saving setting/${settingName}:`, error);
    throw error;
  }
}
