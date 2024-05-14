require('dotenv').config();
const jwt = require('jsonwebtoken');
console.log('authorize.js');
function authorize(req, res, next) {
    console.log('authorize2.js');
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
        return res.redirect('/pleaseLogin');
    }
}

module.exports = authorize;
