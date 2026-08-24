"use client";

import { useState, useEffect, useRef } from "react";
import { Bell } from "lucide-react";
import Link from "next/link";
import { collection, query, where, onSnapshot } from "firebase/firestore";
import { usePathname, useRouter } from "next/navigation";
import { toast } from "react-hot-toast";
import { db } from "@/lib/firebase";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from "@/context/LanguageContext";

export default function NotificationBell() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const pathname = usePathname();
  const router = useRouter();
  const [unreadCount, setUnreadCount] = useState(0);
  const isFirstLoad = useRef(true);
  const pathnameRef = useRef(pathname);

  useEffect(() => {
    pathnameRef.current = pathname;
  }, [pathname]);

  useEffect(() => {
    if (!user) return;

    const q = query(collection(db, "adminNotifications"), where("read", "==", false));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setUnreadCount(snapshot.docs.length);

      if (isFirstLoad.current) {
        isFirstLoad.current = false;
        return;
      }

      if (pathnameRef.current !== '/notifications') {
        snapshot.docChanges().forEach((change) => {
          if (change.type === "added") {
            toast.success(t('new_notification_received'), {
              position: 'top-right',
              duration: 4000,
            });
          }
        });
      }
    }, (error) => {
      console.error("Error listening to notifications:", error);
    });

    return () => unsubscribe();
  }, [user]);

  return (
    <Link href="/notifications" className="relative p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50 transition-colors">
      <Bell className="h-5 w-5" />
      {unreadCount > 0 && (
        <span className="absolute top-1 right-1 flex items-center justify-center h-4 w-4 text-[10px] font-bold text-white bg-red-500 rounded-full">
          {unreadCount > 99 ? '99+' : unreadCount}
        </span>
      )}
    </Link>
  );
}
