"use client";

import { createContext, useContext, useState, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { onAuthStateChanged, signOut, User as FirebaseUser } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import Cookies from "js-cookie";

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface AuthContextType {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
  login: (userData: User) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser: FirebaseUser | null) => {
      setLoading(true);
      if (firebaseUser) {
        try {
          // Fetch additional user claims/role from Firestore
          const docRef = doc(db, "admins", firebaseUser.uid);
          const docSnap = await getDoc(docRef);

          if (docSnap.exists()) {
            const data = docSnap.data();
            const userData: User = {
              id: firebaseUser.uid,
              name: data.name || firebaseUser.displayName || "Admin",
              email: firebaseUser.email || "",
              role: data.role || "ADMIN",
            };
            setUser(userData);
            setIsAuthenticated(true);

            // Set cookie for middleware if needed
            const token = await firebaseUser.getIdToken();
            Cookies.set("token", token, { expires: 1 });
          } else {
            // Not found in admins collection
            await signOut(auth);
            setIsAuthenticated(false);
            setUser(null);
            Cookies.remove("token");
          }
        } catch (error) {
          console.error("Error fetching admin doc:", error);
          setIsAuthenticated(false);
          setUser(null);
        }
      } else {
        setIsAuthenticated(false);
        setUser(null);
        Cookies.remove("token");
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  // Handle redirect if logged in and on login page
  useEffect(() => {
    if (!loading && isAuthenticated && pathname === "/login") {
      router.push("/dashboard");
    }
  }, [loading, isAuthenticated, pathname, router]);

  const login = (userData: User) => {
    // With Firebase, onAuthStateChanged handles the state.
    // This function can be used for manual overrides if absolutely necessary, but usually not needed.
    setUser(userData);
    setIsAuthenticated(true);
    router.push("/dashboard");
  };

  const logout = async () => {
    await signOut(auth);
    Cookies.remove("token");
    setIsAuthenticated(false);
    setUser(null);
    router.push("/login");
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, loading, login, logout }}>
      {!loading && children}
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
