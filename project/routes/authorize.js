require('dotenv').config();
const router = require('express').Router();
// authorize.js

const jwt = require('jsonwebtoken');


function authorize(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(' ')[1]; // Extract token from "Bearer <token>"
        

        if (!token) {
            return res.redirect('/pleaseLogin');
        }

        jwt.verify(token, process.env.SECRET, (err, decoded) => {
            if (err) {
                console.error(err);
                return res.redirect('/pleaseLogin');
            }
            req.user = decoded;

            next();
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}




module.exports = router;
