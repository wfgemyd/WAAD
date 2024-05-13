require('dotenv').config();
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const router = require('express').Router();
const db = require('./postgres');

router.post('/', async (req, res) => {
    const { username, password } = req.body;
    try {
        const sql = `
            SELECT id, full_name, username, password
            FROM power_users
            WHERE username = $1
        `;
        const values = [username];
        const result = await db.query(sql, values);
        if (result.rowCount) {
            const user = result.rows[0];
            const passwordMatch = await bcrypt.compare(password, user.password); // Assuming passwords are hashed

            if (passwordMatch) {
                const tokenPayload = {
                    uId: user.id,
                    username: user.username,
                    fullName: user.full_name
                };
                const token = jwt.sign(tokenPayload, process.env.SECRET, { expiresIn: '10h' });
                res.json({
                    token: token,
                    uId: tokenPayload.uId,
                    fullName: tokenPayload.fullName,
                    username: tokenPayload.username,
                    success: true
                });
                console.log("User logged in successfully");
            } else {
                console.log("Invalid password");
                res.status(401).json({ success: false, message: 'Invalid password' });
            }
        } else {
            console.log("User not found");
            res.status(401).json({ success: false, message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

module.exports = router;






