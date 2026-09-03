'use server';

import { adminDb, adminMessaging } from '@/lib/firebase-admin';

export async function sendNotificationToUser(
  customerId: string,
  type: string,
  title: string,
  body: string,
  payload: any = {},
  resourceId: string = ''
) {
  try {
    if (!customerId) return { success: false, error: 'customerId is required' };

    // 1. Save Notification Document in Firestore
    const notificationId = `${resourceId || type}-${Date.now()}`;
    const userNotificationRef = adminDb
      .collection('users')
      .doc(customerId)
      .collection('notifications')
      .doc(notificationId);

    await userNotificationRef.set({
      id: userNotificationRef.id,
      type,
      resourceId,
      title,
      body,
      read: false,
      createdAt: new Date(),
      payload,
    });

    // 2. Fetch User FCM Tokens
    const userDoc = await adminDb.collection('users').doc(customerId).get();
    if (!userDoc.exists) return { success: true, sent: 0 };

    const userData = userDoc.data() || {};
    const storedTokens = Array.isArray(userData.fcmTokens)
      ? userData.fcmTokens.filter((token: unknown) => typeof token === 'string' && token.trim())
      : [];
    const legacyToken = typeof userData.fcmToken === 'string' && userData.fcmToken.trim()
      ? [userData.fcmToken.trim()]
      : [];

    const uniqueTokens = [...new Set([...storedTokens, ...legacyToken])] as string[];
    
    if (uniqueTokens.length === 0) {
      return { success: true, sent: 0 };
    }

    // 3. Send Push Notification via FCM
    const result = await adminMessaging.sendEachForMulticast({
      tokens: uniqueTokens,
      notification: {
        title,
        body,
      },
      data: {
        type,
        resourceId,
        ...payload,
      },
      android: {
        priority: 'high',
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    });

    return { success: true, sent: result.successCount };
  } catch (error) {
    console.error('Error sending notification:', error);
    return { success: false, error: 'Failed to send notification' };
  }
}

export async function sendBroadcastNotification(title: string, body: string, payload: any = {}) {
  try {
    const usersSnap = await adminDb.collection('users').get();
    const allTokens: string[] = [];
    const userIds: string[] = [];

    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data() || {};
      const fcmTokens = Array.isArray(userData.fcmTokens)
        ? userData.fcmTokens.filter((token: unknown) => typeof token === 'string' && token.trim())
        : [];
      const legacyToken = typeof userData.fcmToken === 'string' && userData.fcmToken.trim()
        ? [userData.fcmToken.trim()]
        : [];

      const uniqueTokens = [...new Set([...fcmTokens, ...legacyToken])] as string[];
      if (uniqueTokens.length === 0) continue;

      userIds.push(userDoc.id);
      allTokens.push(...uniqueTokens);

      const notificationId = `${Date.now()}-${userDoc.id}`;
      await userDoc.ref.collection('notifications').doc(notificationId).set({
        id: notificationId,
        type: 'ADMIN_BROADCAST',
        title,
        body,
        read: false,
        createdAt: new Date(),
        payload: {
          target: 'ALL_USERS',
          ...payload
        },
      });
    }

    if (allTokens.length > 0) {
      const uniqueAllTokens = [...new Set(allTokens)];
      
      await adminMessaging.sendEachForMulticast({
        tokens: uniqueAllTokens,
        notification: { title, body },
        data: { type: 'ADMIN_BROADCAST', title, body, ...payload },
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default', badge: 1 } } },
      });
    }

    const adminNotificationRef = adminDb.collection('adminNotifications').doc();
    await adminNotificationRef.set({
      id: adminNotificationRef.id,
      type: 'ADMIN_BROADCAST',
      title,
      body,
      read: false,
      createdAt: new Date(),
      target: 'ALL_USERS',
      recipients: userIds.length,
    });

    return { success: true, recipients: userIds.length };
  } catch (error) {
    console.error('Error broadcasting notification:', error);
    return { success: false, error: 'Failed to broadcast' };
  }
}
