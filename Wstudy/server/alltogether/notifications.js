// alltogether/notifications.js
require('dotenv').config();
const router = require('express').Router();
const db = require('./postgres');

router.get('/unread/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;
        const result = await db.query('SELECT * FROM Fproject.notifications WHERE user_id = $1 AND read = false', [userId]);
        const count = parseInt(result.rows.length, 10);
        res.json({ count });
    } catch (err) {
        console.error('Error retrieving unread notifications:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.put('/read/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;
        await db.query('UPDATE Fproject.notifications SET read = true WHERE user_id = $1', [userId]);
        res.sendStatus(200);
    } catch (err) {
        console.error('Error marking notifications as read:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;
