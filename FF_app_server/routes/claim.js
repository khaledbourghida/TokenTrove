import express from 'express'
import admin from 'firebase-admin'
import dotenv from 'dotenv'

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const router = express.Router();

router.post("/claim-reward", async (req, res) => {
  try {
    const { linkId , uid } = req.query;
    // const idToken = req.headers.authorization?.split(' ')[1];

    if (!uid || !linkId) {
      return res.status(400).json({ error: "Missing token or linkId" });
    }

    const today = new Date().toISOString().slice(0, 10); // "2025-08-25"

    const claimRef = admin.firestore()
      .collection("claims")
      .doc(uid)
      .collection(today)
      .doc(linkId);

    const claimDoc = await claimRef.get();

    if (claimDoc.exists) {
      return res.status(400).json({ error: "Already claimed" });
    }
    const userRef = admin.firestore().collection("users").doc(uid);
    await admin.firestore().runTransaction(async (t) => {
      const userDoc = await t.get(userRef);
      const currentTokens = userDoc.exists ? userDoc.data().totalTokenCount || 0 : 0;
      t.set(userRef, { totalTokenCount: currentTokens + 10 }, { merge: true });
      t.set(claimRef, { claimedAt: admin.firestore.FieldValue.serverTimestamp() });
    });

    return res.json({ success: true, tokens: 10 });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: "Server error" });
  }
});

export default router
