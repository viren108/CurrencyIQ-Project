// index.js

const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

exports.checkPriceAlerts = onSchedule("every 60 minutes", async (event) => {
    try {
      // 1. Get current exchange rates from Frankfurter API
      const response = await axios.get("https://api.frankfurter.app/latest?from=USD");
      const rates = response.data.rates;

      // 2. Get all active alerts from Firestore
      const alertsSnapshot = await db.collection("alerts").get();
      if (alertsSnapshot.empty) {
        console.log("No active alerts found.");
        return null;
      }

      const promises = [];

      // 3. Loop through each alert to check if the condition is met
      alertsSnapshot.forEach((doc) => {
        const alert = doc.data();
        const currentRate = rates[alert.targetCurrency];

        if (!currentRate) return;

        let conditionMet = false;
        if (alert.condition === "above" && currentRate > alert.targetPrice) {
          conditionMet = true;
        } else if (alert.condition === "below" && currentRate < alert.targetPrice) {
          conditionMet = true;
        }

        if (conditionMet) {
          // 4. If condition is met, send a notification and delete the alert
          promises.push(sendNotification(alert, currentRate));
          promises.push(doc.ref.delete());
        }
      });

      return Promise.all(promises);
    } catch (error) {
      console.error("Error in checkPriceAlerts:", error);
      return null;
    }
  });

async function sendNotification(alert, currentRate) {
  // Get the user's FCM token
  const userDoc = await db.collection("users").doc(alert.userID).get();
  if (!userDoc.exists || !userDoc.data().fcmToken) {
    console.log(`User ${alert.userID} not found or has no FCM token.`);
    return;
  }
  const fcmToken = userDoc.data().fcmToken;

  const payload = {
    notification: {
      title: "CurrencyIQ Price Alert! 💸",
      body:
        `USD/${alert.targetCurrency} is now ${currentRate.toFixed(4)}. ` +
        `Your target was to be alerted when it went ${alert.condition} ${alert.targetPrice}.`,
    },
    token: fcmToken,
  };

  console.log(`Sending notification to user ${alert.userID}`);
  return messaging.send(payload);
}
