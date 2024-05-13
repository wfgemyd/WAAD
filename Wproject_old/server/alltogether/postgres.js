require('dotenv').config({ path: './alltogether/.env' });
const { Pool } = require('pg');
const temp = JSON.parse(process.env.POSTGRES);
const pool = new Pool(temp);
module.exports = {
    query: (sql, params) => pool.query(sql, params)
};

/*Purpose: Establishes and exports a connection pool to the PostgreSQL database using
configuration from the .env file.
Key Components:
Pool : A client pool from the pg (node-postgres) library for managing multiple database
connections efficiently.
pool.query : Exports a function that allows executing SQL queries against the database
using the pool. */