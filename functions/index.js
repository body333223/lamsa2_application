const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * 1. إرسال إشعار عند رد الدعم الفني في الشات
 */
exports.onChatMessage = functions.firestore
    .document('chats/{userId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();
        const userId = context.params.userId;

        if (data.isAdmin === true) {
            try {
                const userDoc = await admin.firestore().collection('users').doc(userId).get();
                const fcmToken = userDoc.data()?.fcmToken;

                if (fcmToken) {
                    const message = {
                        notification: {
                            title: 'رد جديد من الدعم الفني',
                            body: data.text || 'لديك رسالة جديدة',
                        },
                        data: {
                            type: 'chat',
                            userId: userId,
                        },
                        token: fcmToken,
                    };

                    await admin.messaging().send(message);
                }
            } catch (error) {
                console.error('Error sending chat notification:', error);
            }
        }
        return null;
    });

/**
 * 2. إرسال إشعارات العروض العامة (Broadcast)
 *    - لما تضيف document في collection "notifications" من الداشبورد
 *    - لو userId = 'all' → يبعت لكل المستخدمين عبر topic
 *    - لو userId = uid محدد → يبعت لمستخدم واحد
 */
exports.onBroadcastNotification = functions.firestore
    .document('notifications/{docId}')
    .onCreate(async (snapshot) => {
        const data = snapshot.data();
        const targetUserId = data.userId || 'all';

        try {
            if (targetUserId === 'all') {
                // Send to all users via topic
                const message = {
                    notification: {
                        title: data.title || 'إشعار جديد من لمسة',
                        body: data.body || '',
                    },
                    data: {
                        type: 'broadcast',
                        notificationId: snapshot.id,
                    },
                    topic: 'all',
                };
                await admin.messaging().send(message);
            } else {
                // Send to specific user
                const userDoc = await admin.firestore().collection('users').doc(targetUserId).get();
                const fcmToken = userDoc.data()?.fcmToken;

                if (fcmToken) {
                    const message = {
                        notification: {
                            title: data.title || 'إشعار جديد',
                            body: data.body || '',
                        },
                        data: {
                            type: 'personal',
                            notificationId: snapshot.id,
                        },
                        token: fcmToken,
                    };
                    await admin.messaging().send(message);
                }
            }
            await snapshot.ref.update({ status: 'delivered' });
        } catch (error) {
            console.error('Error sending notification:', error);
            await snapshot.ref.update({ status: 'failed', error: error.message });
        }
        return null;
    });

/**
 * 3. إشعار عند تغيير حالة الحجز (من الداشبورد)
 *    - لما الأدمن يغير status الحجز → يوصل إشعار للمستخدم
 */
exports.onBookingStatusChange = functions.firestore
    .document('bookings/{bookingId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Only trigger if status actually changed
        if (before.status === after.status) return null;

        const userId = after.userId;
        if (!userId) return null;

        try {
            const userDoc = await admin.firestore().collection('users').doc(userId).get();
            const fcmToken = userDoc.data()?.fcmToken;

            if (!fcmToken) return null;

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

            const message = {
                notification: { title, body },
                data: {
                    type: 'booking_update',
                    bookingId: context.params.bookingId,
                    status: after.status,
                },
                token: fcmToken,
            };

            await admin.messaging().send(message);

            // Also save notification in Firestore for in-app history
            await admin.firestore().collection('notifications').add({
                title: title,
                body: body,
                userId: userId,
                type: 'booking_update',
                bookingId: context.params.bookingId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
            });

        } catch (error) {
            console.error('Error sending booking notification:', error);
        }
        return null;
    });

/**
 * 4. إضافة نقاط للمستخدم عند إكمال الحجز
 *    - كل حجز مكتمل = 50 نقطة
 */
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
            } catch (error) {
                console.error('Error adding points:', error);
            }
        }
        return null;
    });
