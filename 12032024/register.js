require('dotenv').config();
const jwt = require("jsonwebtoken");
const router = require('express').Router();
const db = require('./postgres');
const bcrypt = require('bcrypt');

function makeToken(user) {
    return jwt.sign(user, process.env.SECRET, { expiresIn: '12h' });
}


router.post('/register', async (req, res) => {
    const { username, password } = req.body;

    // Hash the password before storing it in the database
    const hashedPassword = await bcrypt.hash(password, 10);

    const sql = `INSERT INTO user_detail (username, password) VALUES ($1, $2)`;
    const values = [username, hashedPassword];

    try {
        await db.query(sql, values);
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        console.error(error);
        if (error.constraint === 'user_details_username_key') {
            res.status(409).json({ error: 'Username is already taken' });
        } else {
            res.status(500).json({ error: 'An error occurred while registering the user' });
        }
    }
});

module.exports = router;