import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase';
import { deleteDoc, doc, collection, getDocs } from 'firebase/firestore';

export async function GET() {
  try {
    // 1. Delete setting/legalPolicies
    await deleteDoc(doc(db, 'setting', 'legalPolicies'));

    // 2. Delete all faqs
    const faqsSnapshot = await getDocs(collection(db, 'faqs'));
    for (const d of faqsSnapshot.docs) {
      await deleteDoc(doc(db, 'faqs', d.id));
    }

    return NextResponse.json({ success: true, deletedFaqs: faqsSnapshot.size });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
