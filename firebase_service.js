// Firebase Service - Handles Database and Notifications

// Initialize Firebase (Assumes firebase scripts are loaded in HTML)
let db;
let messaging;

function initFirebase() {
    if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
    }
    db = firebase.firestore();
    try {
        messaging = firebase.messaging();
    } catch (e) {
        console.warn("Firebase Messaging not supported (likely due to http vs https or browser privacy settings):", e);
    }
}

// --- Data Synchronization ---

/**
 * Subscribes to real-time updates for a collection
 * @param {string} collectionName - 'areas', 'employees', 'schedules'
 * @param {function} callback - Function to call with new data array
 */
function subscribeToCollection(collectionName, callback) {
    if (!db) initFirebase();

    return db.collection(collectionName).onSnapshot((snapshot) => {
        const data = [];
        snapshot.forEach((doc) => {
            data.push(doc.data());
        });
        console.log(`Received update for ${collectionName}:`, data.length, "items");
        callback(data);
    }, (error) => {
        console.error(`Error getting ${collectionName}:`, error);
    });
}

/**
 * Saves a single item to a collection (Upsert)
 * @param {string} collectionName 
 * @param {object} item - Must have an 'id' field
 */
async function saveItem(collectionName, item) {
    if (!db) initFirebase();
    // Ensure ID is a string for Firestore document keys
    const docId = String(item.id);
    await db.collection(collectionName).doc(docId).set(item);
}

/**
 * Deletes an item from a collection
 * @param {string} collectionName 
 * @param {string|number} itemId 
 */
async function deleteItem(collectionName, itemId) {
    if (!db) initFirebase();
    await db.collection(collectionName).doc(String(itemId)).delete();
}

/**
 * Batch save all data (Migration utility or bulk update)
 * Use carefully - Firestore charges per write!
 */
async function saveAllData(areas, employees, schedules) {
    if (!db) initFirebase();

    const batch = db.batch();

    areas.forEach(a => {
        const ref = db.collection('areas').doc(String(a.id));
        batch.set(ref, a);
    });

    employees.forEach(e => {
        const ref = db.collection('employees').doc(String(e.id));
        batch.set(ref, e);
    });

    schedules.forEach(s => {
        const ref = db.collection('schedules').doc(String(s.id));
        batch.set(ref, s);
    });

    await batch.commit();
    console.log("All data saved to Firestore");
}

// --- Notifications ---

async function requestNotificationPermission() {
    if (!messaging) return null;

    try {
        const permission = await Notification.requestPermission();
        if (permission === 'granted') {
            const token = await messaging.getToken({ vapidKey: "YOUR_PUBLIC_VAPID_KEY_HERE" });
            // Note: VAPID key is optional for basic setup but recommended. 
            // For now we'll try without or let Firebase handle default.
            console.log("Notification Token:", token);
            return token;
        } else {
            console.warn("Notification permission denied");
            return null;
        }
    } catch (err) {
        console.error("Unable to get permission to notify.", err);
        return null;
    }
}

function onMessageListener(callback) {
    if (!messaging) return;
    messaging.onMessage((payload) => {
        console.log('Message received. ', payload);
        callback(payload);
    });
}

// --- Global State Management (Replacing LocalStorage) ---

// We will keep the global variables 'areas', 'employees', 'schedules' in window
// But we will update them via the listeners.
if (typeof window.areas === 'undefined') window.areas = [];
if (typeof window.employees === 'undefined') window.employees = [];
if (typeof window.schedules === 'undefined') window.schedules = [];

function startRealtimeSync(updateUICallback) {
    initFirebase();

    subscribeToCollection('areas', (data) => {
        window.areas = data;
        if (updateUICallback) updateUICallback();
    });

    subscribeToCollection('employees', (data) => {
        window.employees = data;
        if (updateUICallback) updateUICallback();
    });

    subscribeToCollection('schedules', (data) => {
        window.schedules = data;
        if (updateUICallback) updateUICallback();
    });

    // Also listen for notifications
    subscribeToCollection('notifications', (data) => {
        // This is a "broadcast" collection for app-internal notifications history
        const existing = JSON.parse(localStorage.getItem('waterNotifications') || '[]');
        // Merge? Or just replace? For simplicity, let's trust the server history
        // But we need to handle "read" status locally if we want.
        // For now, let's just save to local storage to keep existing UI working
        if (data.length > 0) {
            localStorage.setItem('waterNotifications', JSON.stringify(data));
            // Trigger UI update if needed
            if (updateUICallback) updateUICallback();
        }
    });
}

async function broadcastNotification(notification) {
    if (!db) initFirebase();
    // Save to 'notifications' collection
    await saveItem('notifications', notification);

    // In a real backend, a Cloud Function would trigger the FCM send.
    // Since we are "Serverless" without Cloud Functions (unless paid), 
    // we rely on the client listening to the 'notifications' collection 
    // and showing a local toast/alert if the app is open.
    // For background notifications, we really need Cloud Functions.
    // BUT, for this "Free" tier request, we will simulate it by having
    // all open clients receive the data update and show a notification.
}
