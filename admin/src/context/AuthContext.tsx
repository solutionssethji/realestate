"use client";

import { createContext, useContext, useState, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import {
  onAuthStateChanged,
  onIdTokenChanged,
  signOut,
  sendEmailVerification,
  User as FirebaseUser,
} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import Cookies from "js-cookie";

const AUTH_TOKEN_COOKIE = "token";
const TOKEN_REFRESH_MARGIN_MS = 5 * 60 * 1000;

async function syncAuthCookie(firebaseUser: FirebaseUser | null) {
  if (!firebaseUser) {
    Cookies.remove(AUTH_TOKEN_COOKIE);
    return null;
  }

  const token = await firebaseUser.getIdToken();
  Cookies.set(AUTH_TOKEN_COOKIE, token, {
    expires: 1,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
  });
  return token;
}

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  photoURL?: string;
}

interface AuthContextType {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
  login: (userData: User) => void;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
  unverifiedFirebaseUser: FirebaseUser | null;
  clearUnverifiedFirebaseUser: () => void;
  resendVerificationEmail: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [initialLoading, setInitialLoading] = useState<boolean>(true);
  const [unverifiedFirebaseUser, setUnverifiedFirebaseUser] = useState<FirebaseUser | null>(null);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser: FirebaseUser | null) => {
      if (firebaseUser) {
        setLoading(true);
        try {
          const adminRef = doc(db, "admins", firebaseUser.uid);
          const adminSnap = await getDoc(adminRef);

          if (adminSnap.exists()) {
            const data = adminSnap.data();
            setUser({
              id: firebaseUser.uid,
              name: data.name || firebaseUser.displayName || "Admin",
              email: firebaseUser.email || "",
              role: data.role || "ADMIN",
              photoURL: data.photoURL || "",
            });
            setIsAuthenticated(true);
            setUnverifiedFirebaseUser(null);
            await syncAuthCookie(firebaseUser);
            setLoading(false);
            setInitialLoading(false);
          } else {
            const { doc: docFn, getDoc: getDocFn } = await import("firebase/firestore");
            const agentSnap = await getDocFn(docFn(db, "agents", firebaseUser.uid));

            if (agentSnap.exists()) {
              const data = agentSnap.data();

              if (data.status !== "ACTIVE") {
                await signOut(auth);
                setIsAuthenticated(false);
                setUser(null);
                Cookies.remove(AUTH_TOKEN_COOKIE);
                setLoading(false);
                setInitialLoading(false);
                return;
              }

              if (!firebaseUser.emailVerified) {
                setUnverifiedFirebaseUser(firebaseUser);
                setLoading(false);
                setInitialLoading(false);
                await signOut(auth);
              } else {
                setUser({
                  id: firebaseUser.uid,
                  name: data.fullName || data.name || firebaseUser.displayName || "Agent",
                  email: firebaseUser.email || "",
                  role: data.role || "AGENT",
                  photoURL: data.photoURL || "",
                });
                setIsAuthenticated(true);
                setUnverifiedFirebaseUser(null);
                await syncAuthCookie(firebaseUser);
                setLoading(false);
                setInitialLoading(false);
              }
            } else {
              await signOut(auth);
              setIsAuthenticated(false);
              setUser(null);
              Cookies.remove(AUTH_TOKEN_COOKIE);
              setLoading(false);
              setInitialLoading(false);
            }
          }
        } catch (error) {
          console.error("AuthContext error:", error);
          setIsAuthenticated(false);
          setUser(null);
          setLoading(false);
          setInitialLoading(false);
        }
      } else {
        setIsAuthenticated(false);
        setUser(null);
        Cookies.remove(AUTH_TOKEN_COOKIE);
        setLoading(false);
        setInitialLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const refreshTokenLoop = async () => {
      if (!auth.currentUser) return;

      try {
        const tokenResult = await auth.currentUser.getIdTokenResult();
        const expirationTime = new Date(tokenResult.expirationTime).getTime();
        const refreshInMs = Math.max(expirationTime - Date.now() - TOKEN_REFRESH_MARGIN_MS, 1000);

        const timeoutId = window.setTimeout(async () => {
          try {
            await auth.currentUser?.getIdToken(true);
            await syncAuthCookie(auth.currentUser);
          } catch (error) {
            console.warn("Token refresh failed", error);
          }
          refreshTokenLoop();
        }, refreshInMs);

        return () => window.clearTimeout(timeoutId);
      } catch (error) {
        console.warn("Failed to schedule token refresh", error);
      }
    };

    let cleanup: (() => void) | undefined;

    const setupRefresh = async () => {
      cleanup = await refreshTokenLoop();
    };

    setupRefresh();

    const unsubscribe = onIdTokenChanged(auth, async (firebaseUser) => {
      if (!firebaseUser) {
        Cookies.remove(AUTH_TOKEN_COOKIE);
        return;
      }

      await syncAuthCookie(firebaseUser);
      cleanup?.();
      setupRefresh();
    });

    return () => {
      unsubscribe();
      cleanup?.();
    };
  }, [user?.id]);

  useEffect(() => {
    if (!loading && isAuthenticated && pathname === "/login") {
      router.push(user?.role === "AGENT" ? "/projects" : "/dashboard");
    }
  }, [loading, isAuthenticated, pathname, router, user?.role]);

  const login = (userData: User) => {
    setUser(userData);
    setIsAuthenticated(true);
    router.push(userData.role === "AGENT" ? "/projects" : "/dashboard");
  };

  const updateUser = (updates: Partial<User>) => {
    if (user) setUser({ ...user, ...updates });
  };

  const logout = async () => {
    await signOut(auth);
    Cookies.remove("token");
    setIsAuthenticated(false);
    setUser(null);
    router.push("/login");
  };

  const clearUnverifiedFirebaseUser = () => setUnverifiedFirebaseUser(null);

  const resendVerificationEmail = async () => {
    if (!unverifiedFirebaseUser) return;
    await sendEmailVerification(unverifiedFirebaseUser);
  };

  return (
    <AuthContext.Provider value={{
      isAuthenticated, user, loading, login, logout, updateUser,
      unverifiedFirebaseUser, clearUnverifiedFirebaseUser, resendVerificationEmail,
    }}>
      {!initialLoading && children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
