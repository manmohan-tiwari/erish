/**
 * ERISH Administrator Privilege Grant Utility
 * Usage: node set_admin.js <user-email-or-uid>
 */
const admin = require("firebase-admin");

if (process.argv.length < 3) {
  console.log("Usage: node set_admin.js <user-email>");
  process.exit(1);
}

const targetEmail = process.argv[2];

if (!admin.apps.length) {
  admin.initializeApp();
}

async function grantAdmin(email) {
  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });

    // Record in Firestore /admins/
    await admin.firestore().collection("admins").doc(user.uid).set({
      email: user.email,
      grantedAt: admin.firestore.FieldValue.serverTimestamp(),
      role: "super_admin",
    });

    console.log(`Success: Granted admin privileges to ${email} (UID: ${user.uid})`);
  } catch (error) {
    console.error(`Error granting admin claim:`, error);
  }
}

grantAdmin(targetEmail);