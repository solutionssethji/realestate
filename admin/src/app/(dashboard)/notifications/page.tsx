"use client";

import { useState, useEffect } from "react";
import { collection, getDocs, query, orderBy, limit, startAfter, doc, updateDoc, onSnapshot } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Bell, Loader2, CheckCircle2, Circle, Check } from "lucide-react";
import { toast } from "react-hot-toast";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { formatRelativeTime } from "@/lib/formatters";

type AppNotification = {
  id: string;
  type: string;
  relatedId: string;
  title: string;
  message: string;
  read: boolean;
  createdAt: any;
};

const PAGE_SIZE = 20;

export default function NotificationsPage() {
  const { t } = useLanguage();
  const router = useRouter();
  const { user } = useAuth();

  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(true);
  const [limitCount, setLimitCount] = useState(PAGE_SIZE);
  const [hasMore, setHasMore] = useState(false);

  useEffect(() => {
    setLoading(true);
    const q = query(
      collection(db, "adminNotifications"),
      orderBy("createdAt", "desc"),
      limit(limitCount)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetched: AppNotification[] = [];
      snapshot.forEach((doc) => {
        fetched.push({ id: doc.id, ...doc.data() } as AppNotification);
      });
      setNotifications(fetched);
      setHasMore(snapshot.docs.length === limitCount);
      setLoading(false);
    }, (error) => {
      console.error(error);
      toast.error("Failed to load notifications");
      setLoading(false);
    });

    return () => unsubscribe();
  }, [limitCount]);

  const handleNotificationClick = async (notification: AppNotification) => {
    if (!notification.read) {
      try {
        await updateDoc(doc(db, "adminNotifications", notification.id), {
          read: true,
          readAt: new Date().toISOString(),
          readBy: user?.id || 'Admin'
        });

        setNotifications(notifications.map(n =>
          n.id === notification.id ? { ...n, read: true } : n
        ));
      } catch (error) {
        console.error("Failed to mark as read", error);
      }
    }

    if (notification.type === 'SITE_VISIT' && notification.relatedId) {
      router.push(`/site-visits?id=${notification.relatedId}`);
    } else if (notification.type === 'ENQUIRY' && notification.relatedId) {
      router.push(`/enquiries?id=${notification.relatedId}`);
    }
  };

  const markAllAsRead = async () => {
    try {
      const unreadNotifs = notifications.filter(n => !n.read);
      if (unreadNotifs.length === 0) return;

      const batchPromises = unreadNotifs.map(n =>
        updateDoc(doc(db, "adminNotifications", n.id), {
          read: true,
          readAt: new Date().toISOString(),
          readBy: user?.id || 'Admin'
        })
      );

      await Promise.all(batchPromises);
      toast.success("All visible notifications marked as read");

      setNotifications(notifications.map(n => ({ ...n, read: true })));
    } catch (error) {
      toast.error("Failed to mark all as read");
    }
  };

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Notifications"
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Notifications" }]}
        actions={
          <Button variant="secondary" onClick={markAllAsRead} icon={<Check className="h-4 w-4" />}>
            Mark all as read
          </Button>
        }
      />

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && notifications.length === 0 ? (
          <div className="flex flex-col space-y-4 p-6">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex space-x-4 animate-pulse">
                <div className="h-4 w-4 rounded-full bg-slate-200 mt-1"></div>
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-slate-200 rounded w-1/4"></div>
                  <div className="h-3 bg-slate-200 rounded w-3/4"></div>
                </div>
              </div>
            ))}
          </div>
        ) : notifications.length === 0 ? (
          <EmptyState
            icon={<Bell className="h-12 w-12 text-slate-300" />}
            title={t('no_notifications')}
            description="You're all caught up! There are no new notifications to review."
          />
        ) : (
          <ul className="divide-y divide-slate-100">
            {notifications.map((notification) => (
              <li
                key={notification.id}
                onClick={() => handleNotificationClick(notification)}
                className={`p-6 hover:bg-slate-50 cursor-pointer transition-colors ${!notification.read ? 'bg-blue-50/20' : ''}`}
              >
                <div className="flex items-start space-x-4">
                  <div className="flex-shrink-0 mt-1">
                    {!notification.read ? (
                      <Circle className="h-3 w-3 fill-blue-500 text-blue-500" />
                    ) : (
                      <CheckCircle2 className="h-5 w-5 text-slate-300" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className={`text-sm font-semibold ${!notification.read ? 'text-slate-900' : 'text-slate-600'}`}>
                      {(notification as any).titleKey ? t((notification as any).titleKey) : notification.title}
                    </p>
                    <p className={`text-sm mt-1 ${!notification.read ? 'text-slate-700' : 'text-slate-500'}`}>
                      {(notification as any).messageKey
                        ? t((notification as any).messageKey, (notification as any).messageParams || {})
                        : notification.message}
                    </p>
                    <p className="text-xs font-medium text-slate-400 mt-3">
                      {formatRelativeTime(notification.createdAt)}
                    </p>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}

        {!loading && hasMore && (
          <div className="p-4 border-t border-slate-100 flex justify-center bg-slate-50/50">
            <Button variant="ghost" onClick={() => setLimitCount(prev => prev + PAGE_SIZE)}>
              Load Older
            </Button>
          </div>
        )}
        {loading && notifications.length > 0 && (
          <div className="flex justify-center p-6 border-t border-slate-100 bg-slate-50/50">
            <Loader2 className="h-6 w-6 animate-spin text-blue-500" />
          </div>
        )}
      </div>
    </div>
  );
}
