const bcrypt = require('bcrypt');
const db = require('./postgres'); // Your database connection module
const express = require('express');
const router = express.Router();

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

module.exports = router;

