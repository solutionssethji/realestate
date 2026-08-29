import { NextResponse } from "next/server";
import { db } from "@/lib/firebase";
import { collection, query, where, getDocs, deleteDoc, doc, updateDoc, getDoc } from "firebase/firestore";

export async function GET(req: Request) {
  try {
    const bookingId = "lqbqleoh0QI2md7GjpG9";
    
    const q = query(
      collection(db, "payments"), 
      where("bookingId", "==", bookingId)
    );
    const snap = await getDocs(q);
    
    const badPayment = snap.docs.find(d => Number(d.data().amount) === 10001);
    
    if (badPayment) {
       await deleteDoc(doc(db, "payments", badPayment.id));
       
       const bookingSnap = await getDoc(doc(db, "assignPlots", bookingId));
       if (bookingSnap.exists()) {
          const currentPaid = Number(bookingSnap.data().paidAmount || 0);
          await updateDoc(doc(db, "assignPlots", bookingId), {
             paidAmount: currentPaid - 10001
          });
          return NextResponse.json({ success: true, msg: "Fixed!" });
       }
    }
    
    return NextResponse.json({ success: false, msg: "Payment not found" });
  } catch (e: any) {
    return NextResponse.json({ success: false, error: e.message });
  }
}
