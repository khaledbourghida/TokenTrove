// routes/referral.js
import express from 'express';
import crypto from 'crypto';
import admin from 'firebase-admin';

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const router = express.Router();
const db = admin.firestore();

// Simple hash generator for IP + UserAgent
function hash(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

// Visitor enters referral link: /ref/:slug
router.get('/:slug', async (req, res) => {
  try {
    const { slug } = req.params;
    const ip =
      req.headers['cf-connecting-ip'] ||
      req.headers['x-real-ip'] ||
      req.headers['x-forwarded-for'] ||
      req.socket.remoteAddress ||
      '0.0.0.0';
    console.log(ip)
    const ipHash = hash(`${ip}`);
    const day = new Date().toISOString().slice(0, 10);

    const refDoc = db.collection('referrals').doc(slug);
    const refSnap = await refDoc.get();
    if (!refSnap.exists || !refSnap.data().active) {
      return res.status(404).send('Invalid referral link');
    }

    // Check if visitor already claimed today
    const claimDoc = refDoc.collection('claims').doc(`${ipHash}-${day}`);
    const claimSnap = await claimDoc.get();
    const userDoc = db.collection('users').doc(refSnap.data().ownerUid);
    const userSnap = await userDoc.get();
    const visitorDoc = db.collection('visitors').doc(day);
    const visitorSnap = await visitorDoc.get();

    const totalReferralVisitors = userSnap.exists ? userSnap.data().totalReferralVisitors || 0 : 0;
    const totalVisitors = refSnap.exists ? refSnap.data().totalVisitors || 0 : 0;
    var dailyVisitors = refSnap.exists ? refSnap.data().dailyVisitors || {} : {};

    dailyVisitors[day] = dailyVisitors[day] ? dailyVisitors[day] + 1 : 1

    if (!claimSnap.exists) {
      if (!visitorSnap.exists) {
        // Create claim
        await claimDoc.set({
          ipHash,
          day,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        await visitorDoc.set({
          ips: { [ipHash]: true },
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        await userDoc.set({
          'totalReferralVisitors': totalReferralVisitors + 1,
        }, { merge: true });

        await refDoc.set({
          'totalVisitors': totalVisitors + 1,
          'dailyVisitors': dailyVisitors
        }, { merge: true });
      } else {
        const data = visitorSnap.data() || {};
        const ips = data.ips || {};

        if (ips[ipHash]) {
          return res.status(200).json({ mssg: 'your are already claimed' })
        } else {
          await visitorDoc.set({ ips: {[`${ipHash}`]: true }}, { merge: true });
          await claimDoc.set({
            ipHash,
            day,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
          });

          await userDoc.set({
            'totalReferralVisitors': totalReferralVisitors + 1,
          }, { merge: true });

          await refDoc.set({
            'totalVisitors': totalVisitors + 1,
            'dailyVisitors': dailyVisitors
          }, { merge: true });
        }
      }
    }

    return res.status(200).json({ mssg: 'Rewards got successfully' });

  } catch (err) {
    console.error('Referral error:', err);
    res.status(500).send('Something went wrong');
  }
});

export default router;
