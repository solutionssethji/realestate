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
            ? "customerEnquiries"
            : col;

      if (id) {
        const docRef = doc(db, collectionName, id);
        const snap = await getDoc(docRef);
        if (!snap.exists()) return errorResponse("Not found");
        return createResponse({ id: snap.id, ...snap.data() });
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
        const data = snap.docs.map((d) => ({
          id: d.id,
          ...(d.data() as Record<string, any>),
        }));

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
            ? "customerEnquiries"
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
            ? "customerEnquiries"
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
            ? "customerEnquiries"
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
