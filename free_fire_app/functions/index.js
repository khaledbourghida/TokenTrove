// firebase deploy --only functions

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const DYNAMIC_LINK_DOMAIN = "tokentrove.page.link"; // 🔧 replace with your domain
const REDIRECT_URL_VERIFY = "https://tokentrove.app/verify-complete";
const REDIRECT_URL_RESET  = "https://tokentrove.app/reset-complete";

function buildActionCodeSettings(redirectUrl) {
  return {
    url: redirectUrl,
    handleCodeInApp: true,
    dynamicLinkDomain: DYNAMIC_LINK_DOMAIN,
  };
}

// Generate verification link
exports.generateEmailVerificationLink = functions.https.onCall(async (data, context) => {
  if (!context.auth?.token?.email) {
    throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
  }
  const email = context.auth.token.email;
  const settings = buildActionCodeSettings(`${REDIRECT_URL_VERIFY}?email=${encodeURIComponent(email)}`);
  const link = await admin.auth().generateEmailVerificationLink(email, settings);
  return { link };
});

// Generate password reset link
exports.generatePasswordResetLink = functions.https.onCall(async (data, context) => {
  const email = data?.email;
  if (!email) throw new functions.https.HttpsError("invalid-argument", "Email is required");
  const settings = buildActionCodeSettings(`${REDIRECT_URL_RESET}?email=${encodeURIComponent(email)}`);
  const link = await admin.auth().generatePasswordResetLink(email, settings);
  return { link };
});
