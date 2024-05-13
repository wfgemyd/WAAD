require('dotenv').config();
const router = require('express').Router();
// authorize.js

const jwt = require('jsonwebtoken');
const rolePermissions = {
    tickets: {
        Administrator: true, // Full access
        Manager: true, // Limited to managed categories
        User: false, // No access or limited access if needed
        'New Employee': false // No access
    }
};

function authorize(req, res, next) {
    try {
        const token = req.headers.authorization;
        const requestedPath = req.path;

        if (!token) {
            return res.redirect('/pleaseLogin');
        }

        jwt.verify(token, process.env.SECRET, (err, decoded) => {
            if (err) {
                console.error(err);
                return res.redirect('/pleaseLogin');
            }
            req.user = decoded;

            // Check if the route is part of the tickets module and if the role is permitted
            if (requestedPath.includes('/api/tickets' || '/api/new_ticket' || '/api/archive')) {
                const isAllowed = rolePermissions.tickets[req.user.role] || false;
                if (!isAllowed) {
                    return res.redirect('/pleaseLogin');
                }
            }

            // Special handling for new employees
            if (req.user.role === 'New Employee' && !requestedPath.startsWith('/api/onboarding')) {
                return res.redirect('/pleaseLogin');
            }

            next();
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}




module.exports = authorize;
