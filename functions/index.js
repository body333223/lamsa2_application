const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ══════════════════════════════════════════════════════════
// Helper: Send push to a single user by token
// ══════════════════════════════════════════════════════════
async function sendPushToUser(userId, title, body, extraData = {}) {
    try {
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;
        if (!fcmToken) return false;

        await admin.messaging().send({
            notification: {
                title: title,
                body: body,
            },
            data: {
                ...extraData,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    title: title,
                    body: body,
                    channelId: 'lamsa_notifications',
                    priority: 'high',
                    defaultSound: true,
                },
            },
            token: fcmToken,
        });
        return true;
    } catch (error) {
        console.error(`Push failed for user ${userId}:`, error.message);
        return false;
    }
}

// ══════════════════════════════════════════════════════════
// 1. Chat: Admin replies → notify user
// ══════════════════════════════════════════════════════════
exports.onChatMessage = functions.firestore
    .document('chats/{userId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();
        const userId = context.params.userId;

        if (data.isAdmin === true) {
            await sendPushToUser(
                userId,
                'رد جديد من الدعم الفني',
                data.text || 'لديك رسالة جديدة',
                { type: 'chat', userId: userId }
            );
        }
        return null;
    });

// ══════════════════════════════════════════════════════════
// 2. Booking status change → notify user (SINGLE source of truth)
// ══════════════════════════════════════════════════════════
exports.onBookingStatusChange = functions.firestore
    .document('bookings/{bookingId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Only trigger if status actually changed
        if (before.status === after.status) return null;

        const userId = after.userId;
        if (!userId) return null;

        let title = '';
        let body = '';

        switch (after.status) {
            case 'confirmed':
                title = 'تم تأكيد حجزك ✅';
                body = `حجزك لخدمة "${after.serviceName}" تم تأكيده بنجاح`;
                break;
            case 'cancelled':
                title = 'تم إلغاء الحجز ❌';
                body = `حجزك لخدمة "${after.serviceName}" تم إلغاؤه`;
                break;
            case 'completed':
                title = 'تم إكمال الخدمة 🎉';
                body = `شكراً لكِ! خدمة "${after.serviceName}" اكتملت بنجاح`;
                break;
            case 'cancel_requested':
                title = 'طلب إلغاء قيد المراجعة';
                body = `طلب إلغاء حجز "${after.serviceName}" قيد المراجعة`;
                break;
            default:
                title = 'تحديث على حجزك';
                body = `حالة حجز "${after.serviceName}" تغيرت`;
        }

        // Send ONE push notification
        await sendPushToUser(userId, title, body, {
            type: 'booking_update',
            bookingId: context.params.bookingId,
            status: after.status,
        });

        // Save in user's notification history (for in-app display only)
        await admin.firestore()
            .collection('users').doc(userId)
            .collection('notifications').add({
                title, body,
                type: 'booking_update',
                bookingId: context.params.bookingId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
            });

        return null;
    });

// ══════════════════════════════════════════════════════════
// 3. Broadcast notifications (from admin dashboard)
//    ONLY triggers for documents added to 'notifications' collection
//    with source='dashboard'
// ══════════════════════════════════════════════════════════
exports.onBroadcastNotification = functions.firestore
    .document('notifications/{docId}')
    .onCreate(async (snapshot) => {
        const data = snapshot.data();

        // ONLY process notifications explicitly from dashboard
        if (data.source !== 'dashboard') {
            return null;
        }

        // Already processed
        if (data.status === 'delivered') {
            return null;
        }

        const targetUserId = data.userId || 'all';
        const title = data.title || 'إشعار جديد من لمسة';
        const body = data.body || '';

        try {
            if (targetUserId === 'all') {
                // Send to all users — get all tokens
                const usersSnap = await admin.firestore()
                    .collection('users')
                    .where('fcmToken', '!=', null)
                    .get();

                const tokens = usersSnap.docs
                    .map(doc => doc.data().fcmToken)
                    .filter(t => t && t.length > 0);

                if (tokens.length > 0) {
                    await admin.messaging().sendEachForMulticast({
                        tokens: tokens,
                        notification: {
                            title: title,
                            body: body,
                        },
                        android: {
                            priority: 'high',
                            notification: {
                                title: title,
                                body: body,
                                channelId: 'lamsa_notifications',
                                priority: 'high',
                                defaultSound: true,
                            },
                        },
                        data: { type: 'broadcast', notificationId: snapshot.id },
                    });
                }
            } else {
                // Send to specific user
                await sendPushToUser(targetUserId, title, body, {
                    type: 'personal',
                    notificationId: snapshot.id,
                });
            }
            await snapshot.ref.update({ status: 'delivered' });
        } catch (error) {
            console.error('Broadcast error:', error.message);
            await snapshot.ref.update({ status: 'failed', error: error.message });
        }
        return null;
    });

// ══════════════════════════════════════════════════════════
// 4. Points: +50 on booking completed
// ══════════════════════════════════════════════════════════
exports.onBookingCompleted = functions.firestore
    .document('bookings/{bookingId}')
    .onUpdate(async (change) => {
        const before = change.before.data();
        const after = change.after.data();

        if (before.status !== 'completed' && after.status === 'completed') {
            const userId = after.userId;
            if (!userId) return null;

            try {
                await admin.firestore().collection('users').doc(userId).set({
                    points: admin.firestore.FieldValue.increment(50),
                }, { merge: true });
            } catch (_) { }
        }
        return null;
    });
