import { collection, doc, runTransaction, type DocumentReference } from "firebase/firestore";
import { db } from "@/lib/firebase";

export async function createPaymentWithVoucher(
  paymentRef: DocumentReference,
  payment: Record<string, unknown>,
) {
  const counterRef = doc(collection(db, "counters"), "payments");

  await runTransaction(db, async (transaction) => {
    const counterSnapshot = await transaction.get(counterRef);
    const lastVoucherNumber = Number(
      counterSnapshot.data()?.lastVoucherNumber || 0,
    );
    const voucherNumber = lastVoucherNumber + 1;

    transaction.set(counterRef, { lastVoucherNumber: voucherNumber }, { merge: true });
    transaction.set(paymentRef, { ...payment, voucherNumber });
  });
}