require('dotenv').config();
const jwt = require("jsonwebtoken");
const router = require('express').Router();
const db = require('./postgres');
const bcrypt = require('bcrypt');
const cors = require('cors');

function makeToken(user) {
    return jwt.sign(user, process.env.SECRET, { expiresIn: '20m' });
}

router.use(cors());

router.post('/login', async (req, res) => {
    console.log(req.body);
    try {
        const sql = `SELECT * FROM user_detail WHERE username = $1`;
        const values = [req.body.username];
        const result = await db.query(sql, values);
        if (result.rowCount) {
            const user = result.rows[0];
            console.log(user);
            if (req.body.password && user.password) {
                const passwordMatch = await bcrypt.compare(req.body.password, user.password);
                if (passwordMatch) {
                    res.json({ token: makeToken({ username: req.body.username }) });
                    console.log("User logged in successfully");
                } else {
                    console.log("Invalid password");
                    res.status(401).end();
                }
            } else {
                console.log("Password not provided or user does not have a password");
                res.status(400).end();
            }
        } else {
            console.log("User not found");
            res.status(404).end();
        }
    } catch (error) {
        console.error(error);
        res.status(500).end();
    }
});




router.post('/register', async (req, res) => {
    const { username, password } = req.body;

    if (!password) {
        return res.status(400).json({ error: 'Password is required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const sql = `INSERT INTO user_detail (username, password) VALUES ($1, $2)`;
        const values = [username, hashedPassword];
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