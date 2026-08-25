"use client";

import { useState, useEffect } from "react";
import { collection, query, orderBy, limit, doc, updateDoc, onSnapshot, getDoc } from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { db, functions } from "@/lib/firebase";
import { Bell, Loader2, CheckCircle2, Circle, Check, Send } from "lucide-react";
import { toast } from "react-hot-toast";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
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
  const [showComposer, setShowComposer] = useState(false);
  const [notificationTitle, setNotificationTitle] = useState("");
  const [notificationBody, setNotificationBody] = useState("");
  const [sendingNotification, setSendingNotification] = useState(false);

  // Map of customerId -> displayName
  const [userNames, setUserNames] = useState<Record<string, string>>({});
  // Map of notificationId -> resolved customerId (if found)
  const [notifCustomerMap, setNotifCustomerMap] = useState<Record<string, string>>({});

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
        const data = doc.data() ?? {};
        const { id: _docDataId, ...rest } = data as any;
        fetched.push({ id: doc.id, ...rest } as AppNotification);
      });
      setNotifications(fetched);
      setHasMore(snapshot.docs.length === limitCount);
      setLoading(false);
    }, (error) => {
      console.error(error);
      toast.error(t('failed_load_notifications'));
      setLoading(false);
    });

    return () => unsubscribe();
  }, [limitCount]);

  // Resolve customer names for notifications (client-side)
  useEffect(() => {
    if (!notifications || notifications.length === 0) {
      setUserNames({});
      setNotifCustomerMap({});
      return;
    }

    let cancelled = false;

    const resolveNames = async () => {
      try {
        const directIds = new Set<string>();
        const assignLookups: { notifId: string; assignId: string }[] = [];

        notifications.forEach((n: any) => {
          // common direct fields
          if (n.customerId) directIds.add(n.customerId);
          if (n.userId) directIds.add(n.userId);
          if (n.payload && n.payload.customerId) directIds.add(n.payload.customerId);
          if (n.messageParams && n.messageParams.customerId) directIds.add(n.messageParams.customerId);

          // If notification references an assignPlots doc (booking/assignment), try to resolve customerId from that doc
          if (!n.customerId && n.relatedId && ['PLOT_ASSIGNED', 'BOOKING', 'PAYMENT'].includes(n.type || '')) {
            assignLookups.push({ notifId: n.id, assignId: n.relatedId });
          }

          if (!n.customerId && n.payload && n.payload.assignmentId) {
            assignLookups.push({ notifId: n.id, assignId: n.payload.assignmentId });
          }
        });

        // Fetch assignPlots docs to extract customerIds
        const assignFetches = assignLookups.map(a =>
          getDoc(doc(db, 'assignPlots', a.assignId)).then(s => ({ notifId: a.notifId, customerId: s.exists() ? (s.data() as any).customerId : null }))
        );

        const assignResults = await Promise.all(assignFetches);
        const notifToCustomer: Record<string, string> = {};
        assignResults.forEach(r => {
          if (r.customerId) {
            directIds.add(r.customerId);
            notifToCustomer[r.notifId] = r.customerId;
          }
        });

        // Batch fetch user docs for all unique customer ids
        const ids = Array.from(directIds);
        const userFetches = ids.map(id =>
          getDoc(doc(db, 'users', id)).then(s => ({ id, data: s.exists() ? s.data() : null }))
        );

        const userResults = await Promise.all(userFetches);
        const nameMap: Record<string, string> = {};
        userResults.forEach(r => {
          if (r.data) {
            const d: any = r.data;
            nameMap[r.id] = d.fullName || d.name || d.displayName || d.email || 'Customer';
          }
        });

        if (cancelled) return;

        setUserNames(nameMap);
        setNotifCustomerMap(notifToCustomer);
      } catch (e) {
        console.warn('Failed to resolve notification user names', e);
      }
    };

    resolveNames();

    return () => { cancelled = true; };
  }, [notifications]);

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

  const handleSendNotification = async () => {
    const title = notificationTitle.trim();
    const body = notificationBody.trim();

    if (!title || !body) {
      toast.error("Please enter both title and message");
      return;
    }

    setSendingNotification(true);
    try {
      const sendNotificationFn = httpsCallable(functions, "sendBroadcastNotification");
      const result: any = await sendNotificationFn({ title, body });
      const payload = result?.data ?? {};
      toast.success(`Notification sent to ${payload.total ?? 0} user(s)`);
      setShowComposer(false);
      setNotificationTitle("");
      setNotificationBody("");
    } catch (error: any) {
      console.error("Failed to send notification", error);
      toast.error(error?.message || "Failed to send notification");
    } finally {
      setSendingNotification(false);
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
      toast.success(t('all_marked_as_read'));

      setNotifications(notifications.map(n => ({ ...n, read: true })));
    } catch (error) {
      toast.error(t('failed_mark_all_read'));
    }
  };

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('notifications')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('notifications') }]}
        actions={
          <div className="flex items-center gap-2">
            <Button variant="primary" onClick={() => setShowComposer(true)} icon={<Send className="h-4 w-4" />}>
              Send Notification
            </Button>
            <Button variant="secondary" onClick={markAllAsRead} icon={<Check className="h-4 w-4" />}>
              {t('mark_all_as_read')}
            </Button>
          </div>
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
            description={t('all_caught_up')}
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
                    {/* Display resolved customer name (if available) */}
                    {(() => {
                      const anyN = notification as any;
                      const directCid = anyN.customerId || anyN.userId || anyN.payload?.customerId || anyN.messageParams?.customerId;
                      const resolvedCid = directCid || notifCustomerMap[notification.id];
                      const displayName = resolvedCid ? userNames[resolvedCid] : null;
                      return displayName ? (
                        <p className="text-sm text-slate-500">{displayName}</p>
                      ) : null;
                    })()}

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
              {t('load_older')}
            </Button>
          </div>
        )}
        {loading && notifications.length > 0 && (
          <div className="flex justify-center p-6 border-t border-slate-100 bg-slate-50/50">
            <Loader2 className="h-6 w-6 animate-spin text-blue-500" />
          </div>
        )}
      </div>

      <Modal
        isOpen={showComposer}
        onClose={() => setShowComposer(false)}
        title="Send push notification"
        maxWidth="md"
        footer={
          <>
            <Button variant="secondary" onClick={() => setShowComposer(false)}>
              Cancel
            </Button>
            <Button variant="primary" onClick={handleSendNotification} disabled={sendingNotification}>
              {sendingNotification ? "Sending..." : "Send to all users"}
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Title</label>
            <input
              type="text"
              value={notificationTitle}
              onChange={(e) => setNotificationTitle(e.target.value)}
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Project launch"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Message</label>
            <textarea
              value={notificationBody}
              onChange={(e) => setNotificationBody(e.target.value)}
              className="w-full min-h-[120px] px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Share a special offer or an important update with all customers."
            />
          </div>
        </div>
      </Modal>
    </div>
  );
}
