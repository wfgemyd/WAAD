const bcrypt = require('bcrypt');
const db = require('./postgres'); // Your database connection module
const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const cors = require('cors');

router.use(bodyParser.json());

async function createUser(fullName, username, plainTextPassword) {
    try {
        // Generate a salt and hash the password
        const saltRounds = 10; // Recommended value
        const hashedPassword = await bcrypt.hash(plainTextPassword, saltRounds);

        // SQL query to insert the new user
        const sql = `
            INSERT INTO power_users (full_name, username, password)
            VALUES ($1, $2, $3)
        `;
        const values = [fullName, username, hashedPassword];

        // Execute the query
        const result = await db.query(sql, values);
        console.log("User created successfully");
    } catch (error) {
        console.error("Error creating user:", error);
    }
}



router.post('/newUser', async (req, res) => {
    const { username, password } = req.body;
    try {
        // Check if username already exists
        const userCheckSql = `SELECT * FROM power_users WHERE username = $1`;
        const userCheckResult = await db.query(userCheckSql, [username]);
        if (userCheckResult.rows.length > 0) {
            return res.status(409).json({ success: false, message: 'Username already exists' });
        }

        // If username does not exist, create new user
        await createUser(username, username, password); // Assuming fullName is the same as username for simplicity
        res.json({ success: true, message: 'User created successfully' });
    } catch (error) {
        console.error("Error registering user:", error);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});


module.exports = router;

