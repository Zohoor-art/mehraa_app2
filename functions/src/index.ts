import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// 1. دالة تحتوي المنطق الكامل
export const sendWeeklyNotificationsLogic = async () => {
  const db = admin.firestore();
  const now = new Date();
  const lastWeek = new Date();
  lastWeek.setDate(now.getDate() - 7);

  // تقييمات هذا الأسبوع
  const ratingsSnap = await db.collection('storeRatings').get();
  const currentRatings: Record<string, number> = {};
  ratingsSnap.docs.forEach(doc => {
    currentRatings[doc.id] = doc.data().averageRating || 0;
  });

  // تقييمات الأسبوع الماضي
  const analyticsSnap = await db
    .collection('analyticsLogs')
    .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(lastWeek))
    .get();
  const lastWeekRatings: Record<string, number> = {};
  analyticsSnap.docs.forEach(doc => {
    const d = doc.data();
    lastWeekRatings[d.sellerId] = d.averageRating;
  });

  // الطلبات المكتملة هذا الأسبوع
  const ordersSnap = await db
    .collectionGroup('orders')
    .where('createdAt', '>', admin.firestore.Timestamp.fromDate(lastWeek))
    .where('status', '==', 'completed')
    .get();

  const sellerOrderCount: Record<string, number> = {};
  const productCounts: Record<string, number> = {};

  ordersSnap.docs.forEach(doc => {
    const sellerId = doc.data().sellerId;
    const postId = doc.data().postId;
    if (sellerId) {
      sellerOrderCount[sellerId] = (sellerOrderCount[sellerId] || 0) + 1;
    }
    if (postId) {
      productCounts[postId] = (productCounts[postId] || 0) + 1;
    }
  });

  // أعلى متجر تقييماً
  const topRated = Object.entries(currentRatings).sort((a, b) => b[1] - a[1])[0];
  const topSellerId = topRated?.[0];
  const topRating = topRated?.[1] ?? 0;
  let topStoreName = 'متجر غير معروف';

  if (topSellerId) {
    const topUserDoc = await db.collection('users').doc(topSellerId).get();
    if (topUserDoc.exists) {
      topStoreName = topUserDoc.data()?.storeName ?? topStoreName;
    }
  }

  // أكثر منتج طلباً
  let topProductDesc = 'منتج غير معروف';
  if (Object.keys(productCounts).length > 0) {
    const topPostId = Object.entries(productCounts).sort((a, b) => b[1] - a[1])[0][0];
    const topPostDoc = await db.collection('posts').doc(topPostId).get();
    if (topPostDoc.exists) {
      topProductDesc = topPostDoc.data()?.productDescription ?? topProductDesc;
    }
  }

  const usersSnap = await db.collection('users').get();

  const batch = db.batch();

  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;
    const storeName = userDoc.data()?.storeName ?? 'متجرك';

    const hasRating = currentRatings[uid] !== undefined;
    const hasOrder = sellerOrderCount[uid] !== undefined;

    const currentRating = currentRatings[uid] ?? 0;
    const previousRating = lastWeekRatings[uid];

    const notifRef = db.collection('notifications').doc(uid).collection('items').doc();

    if (hasRating || hasOrder) {
      let message = `✨ ${storeName}، إليك ملخص الأسبوع:\n`;

      if (previousRating !== undefined && currentRating < previousRating) {
        message += `📉 انخفض تقييمك من ${previousRating.toFixed(1)}⭐ إلى ${currentRating.toFixed(1)}⭐\n`;
      } else {
        message += `⭐ تقييمك هذا الأسبوع: ${currentRating.toFixed(1)}\n`;
      }

      if (hasOrder) {
        message += `📦 عدد الطلبات المكتملة: ${sellerOrderCount[uid]}\n`;
      }

      message += `🏆 الأعلى تقييماً: ${topStoreName}\n🔥 المنتج الأكثر طلباً: "${topProductDesc}"`;

      batch.set(notifRef, {
        id: notifRef.id,
        fromUid: 'admin',
        type: 'analytics',
        message,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      });
    } else {
      batch.set(notifRef, {
        id: notifRef.id,
        fromUid: 'admin',
        type: 'reminder',
        message: `⚠️ ${storeName}، لم تسجل أي تقييمات أو طلبات هذا الأسبوع.\nحاول تنشيط متجرك وزيادة التفاعل 👊`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      });
    }

    const analyticsRef = db.collection('analyticsLogs').doc();
    batch.set(analyticsRef, {
      sellerId: uid,
      averageRating: currentRating,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  console.log('✅ تم إرسال جميع إشعارات الأسبوع حسب النشاط');
};

// 2. دالة تشغيل يدوي عبر HTTP
export const testWeeklyNotifications = functions.https.onRequest(async (req, res) => {
  try {
    await sendWeeklyNotificationsLogic();
    res.status(200).send('✅ تم تنفيذ إشعارات الأسبوع بنجاح.');
  } catch (error) {
    console.error('❌ خطأ:', error);
    res.status(500).send('حدث خطأ أثناء تنفيذ الإشعارات.');
  }
});
