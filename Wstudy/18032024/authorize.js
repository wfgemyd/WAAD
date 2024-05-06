require('dotenv').config();
const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
    const token = req.headers['authorization'];
    if (!token) return res.status(400).end();

    jwt.verify(token, process.env.SECRET, (err, user) => {
        if (err) return res.status(403).end();
        req.user = user;
        next();

    });

};