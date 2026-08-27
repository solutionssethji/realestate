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

export async function createPaymentAndUpdateBooking(
  paymentRef: DocumentReference,
  bookingRef: DocumentReference,
  payment: Record<string, unknown>,
  amount: number,
) {
  const counterRef = doc(collection(db, "counters"), "payments");

  await runTransaction(db, async (transaction) => {
    const [bookingSnapshot, counterSnapshot] = await Promise.all([
      transaction.get(bookingRef),
      transaction.get(counterRef),
    ]);
    if (!bookingSnapshot.exists()) {
      throw new Error("Booking does not exist.");
    }

    const lastVoucherNumber = Number(
      counterSnapshot.data()?.lastVoucherNumber || 0,
    );
    const voucherNumber = lastVoucherNumber + 1;
    const currentPaidAmount = Number(
      bookingSnapshot.data()?.paidAmount || 0,
    );

    transaction.set(
      counterRef,
      { lastVoucherNumber: voucherNumber },
      { merge: true },
    );
    transaction.set(paymentRef, { ...payment, voucherNumber });
    transaction.update(bookingRef, {
      paidAmount: currentPaidAmount + amount,
      updatedAt: new Date().toISOString(),
    });
  });
}