require('dotenv').config();
const jwt = require("jsonwebtoken");
const router = require('express').Router();
const db = require('./postgres');
const bcrypt = require('bcrypt');

function makeToken(user) {
    return jwt.sign(user, process.env.SECRET, { expiresIn: '12h' });
}

router.post('/login', async (req, res) => {
    console.log(req.body);
    try {
        console.log(req.body.username);
        const sql = `SELECT * FROM user_detail WHERE username = $1`;
        const values = [req.body.username];
        const result = await db.query(sql, values);
        console.log(result.rows.length, result.rowCount);
        if (result.rowCount) {
            const user = result.rows[0];
            console.log(user);
            const passwordMatch = await bcrypt.compare(req.body.password, user.password);
            if (passwordMatch) {
                res.json({ token: makeToken({ username: req.body.username }) });
                console.log("User logged in successfully");
            } else {
                console.log("Invalid password");
                res.status(401).end();
            }
        } else {
            res.status(401).end();
        }
    } catch (error) {
        console.error(error);
        res.status(500).end();
    }
});




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