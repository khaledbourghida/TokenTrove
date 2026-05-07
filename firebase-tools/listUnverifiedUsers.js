const admin = require("firebase-admin");
const fs = require("fs");
// Load your service account key
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
credential: admin.credential.cert(serviceAccount)
});

async function listUnverifiedUsers() {
const result = await admin.auth().listUsers(1000); // gets up to 1000 at once
const unverified = result.users
.map(user => user.email);

 // Save to file
 fs.writeFileSync("emails.csv", unverified.join("\n"));

 console.log("✅ Exported unverified emails to unverified_emails.csv");
}

listUnverifiedUsers();
