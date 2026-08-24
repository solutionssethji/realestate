/* eslint-disable react-hooks/immutability */
import {
  collection,
  doc,
  getDocs,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  DocumentSnapshot,
} from "firebase/firestore";
import { db } from "./firebase";

const createResponse = (data: any, lastDoc?: any) => ({
  data: { success: true, data, lastDoc },
});
const errorResponse = (msg: string) =>
  Promise.reject({ response: { data: { success: false, message: msg } } });

async function enrichBookingData(bookingData: any) {
  const fetchPromises = [];

  if (bookingData.customerId && !bookingData.customerName) {
    fetchPromises.push(
      getDoc(doc(db, "users", bookingData.customerId))
        .then((snap) => {
          if (snap.exists()) {
            bookingData.customerName = snap.data().fullName || "Unknown";
          }
        })
        .catch(console.error),
    );
  }

  if (bookingData.projectId && !bookingData.projectName) {
    fetchPromises.push(
      getDoc(doc(db, "projects", bookingData.projectId))
        .then((snap) => {
          if (snap.exists()) {
            const pData = snap.data();
            bookingData.projectName = pData.name?.en || pData.name || "Unknown";
          }
        })
        .catch(console.error),
    );
  }

  if (bookingData.plotId && (!bookingData.plotNumber || !bookingData.status)) {
    fetchPromises.push(
      getDoc(doc(db, "plots", bookingData.plotId))
        .then((snap) => {
          if (snap.exists()) {
            const pData = snap.data();
            bookingData.plotNumber = pData.plotNumber || "Unknown";
            if (!bookingData.status) {
              bookingData.status =
                pData.status === "BOOKED_SOLD"
                  ? "BOOKED"
                  : pData.status || "BOOKED";
            }
          }
        })
        .catch(console.error),
    );
  }

  await Promise.all(fetchPromises);

  if (!bookingData.status) {
    bookingData.status = "BOOKED";
  }

  return bookingData;
}

async function enrichPaymentData(paymentData: any) {
  const fetchPromises = [];

  if (paymentData.customerId && !paymentData.customerName) {
    fetchPromises.push(
      getDoc(doc(db, "users", paymentData.customerId))
        .then((snap) => {
          if (snap.exists()) {
            const d = snap.data();
            paymentData.customerName = d.fullName || d.name || "Unknown";
          }
        })
        .catch(console.error),
    );
  }

  if (paymentData.bookingId && (!paymentData.projectName || !paymentData.plotNumber)) {
    fetchPromises.push(
      getDoc(doc(db, "assignPlots", paymentData.bookingId))
        .then(async (snap) => {
          if (snap.exists()) {
            const bData = snap.data();
            paymentData.projectName = bData.projectName;
            paymentData.plotNumber = bData.plotNumber;
            
            if (!paymentData.projectName && bData.projectId) {
              const pSnap = await getDoc(doc(db, "projects", bData.projectId));
              if (pSnap.exists()) {
                const pData = pSnap.data();
                paymentData.projectName = pData.name?.en || pData.name || "Unknown";
              }
            }
            if (!paymentData.plotNumber && bData.plotId) {
               const plSnap = await getDoc(doc(db, "plots", bData.plotId));
               if (plSnap.exists()) {
                  paymentData.plotNumber = plSnap.data().plotNumber || "Unknown";
               }
            }
          }
        })
        .catch(console.error),
    );
  }

  await Promise.all(fetchPromises);
  return paymentData;
}


export interface ApiGetOptions {
  limitCount?: number;
  startAfterDoc?: DocumentSnapshot | null;
  filters?: { field: string; operator: any; value: any }[];
  sortField?: string;
  sortOrder?: "asc" | "desc";
}

const api = {
  get: async (url: string, options?: ApiGetOptions) => {
    try {
      const parts = url.split("/").filter(Boolean);

      if (parts[0] === "projects" && parts[2] === "plots") {
        const q = query(
          collection(db, "plots"),
          where("projectId", "==", parts[1]),
        );
        const snap = await getDocs(q);
        return createResponse(
          snap.docs.map((d) => ({
            id: d.id,
            ...(d.data() as Record<string, any>),
          })),
        );
      }

      const col = parts[0];
      const id = parts[1];

      // Use siteVisits for site-visits endpoint
      const collectionName =
        col === "site-visits"
          ? "siteVisits"
          : col === "enquiries"
            ? "enquiries"
            : col === "bookings"
              ? "assignPlots"
              : col;

      if (id) {
        const docRef = doc(db, collectionName, id);
        const snap = await getDoc(docRef);
        if (!snap.exists()) return errorResponse("Not found");

        let data = { id: snap.id, ...snap.data() };
        if (collectionName === "assignPlots") {
          data = await enrichBookingData(data);
        } else if (collectionName === "payments") {
          data = await enrichPaymentData(data);
        }

        return createResponse(data);
      } else {
        let baseQuery: any = collection(db, collectionName);

        if (options?.filters) {
          options.filters.forEach((f) => {
            baseQuery = query(baseQuery, where(f.field, f.operator, f.value));
          });
        }

        if (options?.sortField) {
          baseQuery = query(
            baseQuery,
            orderBy(options.sortField, options.sortOrder || "desc"),
          );
        } else if (
          options?.limitCount &&
          (!options.filters || options.filters.length === 0)
        ) {
          // Default to sorting by createdAt desc for most lists to have a stable pagination if limit is provided
          baseQuery = query(baseQuery, orderBy("createdAt", "desc"));
        }

        if (options?.startAfterDoc) {
          baseQuery = query(baseQuery, startAfter(options.startAfterDoc));
        }

        if (options?.limitCount) {
          baseQuery = query(baseQuery, limit(options.limitCount));
        }

        const snap = await getDocs(baseQuery);
        let data = snap.docs.map((d) => ({
          id: d.id,
          ...(d.data() as Record<string, any>),
        }));

        if (collectionName === "assignPlots") {
          data = await Promise.all(data.map((b) => enrichBookingData(b)));
        } else if (collectionName === "payments") {
          data = await Promise.all(data.map((p) => enrichPaymentData(p)));
        }

        const lastVisible =
          snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : undefined;

        return createResponse(data, lastVisible as any);
      }
    } catch (e: any) {
      console.error("API GET Error:", e);
      return Promise.reject(e);
    }
  },

  post: async (url: string, data: any) => {
    try {
      if (url.startsWith("/auth/")) {
        return createResponse({});
      }

      const parts = url.split("/").filter(Boolean);
      const col = parts[0];
      const collectionName =
        col === "site-visits"
          ? "siteVisits"
          : col === "enquiries"
            ? "enquiries"
            : col === "bookings"
              ? "assignPlots"
              : col;

      const newDocRef = doc(collection(db, collectionName));
      const payload = {
        ...data,
        id: newDocRef.id,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      await setDoc(newDocRef, payload);

      return createResponse(payload);
    } catch (e: any) {
      return errorResponse(e.message);
    }
  },

  put: async (url: string, data: any) => {
    try {
      const parts = url.split("/").filter(Boolean);
      const col = parts[0];
      const id = parts[1];
      const collectionName =
        col === "site-visits"
          ? "siteVisits"
          : col === "enquiries"
            ? "enquiries"
            : col === "bookings"
              ? "assignPlots"
              : col;

      const docRef = doc(db, collectionName, id);
      await updateDoc(docRef, { ...data, updatedAt: new Date().toISOString() });

      return createResponse({ id, ...data });
    } catch (e: any) {
      return errorResponse(e.message);
    }
  },

  delete: async (url: string) => {
    try {
      const parts = url.split("/").filter(Boolean);
      const col = parts[0];
      const id = parts[1];
      const collectionName =
        col === "site-visits"
          ? "siteVisits"
          : col === "enquiries"
            ? "enquiries"
            : col;

      await deleteDoc(doc(db, collectionName, id));

      // Cascade delete plots if a project is deleted
      if (collectionName === "projects") {
        const plotsQuery = query(
          collection(db, "plots"),
          where("projectId", "==", id),
        );
        const snap = await getDocs(plotsQuery);
        const deletePromises = snap.docs.map((d) =>
          deleteDoc(doc(db, "plots", d.id)),
        );
        await Promise.all(deletePromises);
      }

      return createResponse(null);
    } catch (e: any) {
      return errorResponse(e.message);
    }
  },
};

export default api;
