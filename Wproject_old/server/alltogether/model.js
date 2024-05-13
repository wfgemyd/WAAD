/*
logic flow:
1.Import the db module, which is responsible for connecting to the database.
2.Define an object with methods for each database operation:
getPosts(): Retrieves all posts from the database.
createPost(newPost): Inserts a new post into the database.
getPostByUUID(uuid): Retrieves a post by its unique identifier (UUID).
updatePostByUUID(uuid, updatedPost): Updates a post by its UUID with the provided updated post details.
deletePostByUUID(uuid): Deletes a post by its UUID from the database.
3.Export the object containing the methods.


Basically, the model.js file is responsible for defining and exporting methods that interact with the database. These methods are used by the routes to perform CRUD operations on the posts table in the database.
*/
/*
const db = require('./postgres');

module.exports = {
    async getPosts() {
        const sql = `SELECT * FROM posts`;
        const result = await db.query(sql);
        return result.rows;
    },
    async createPost(newPost) {
        const { title, body, date, uuid } = newPost;
        const sql = `INSERT INTO posts (title, body, date, uuid) VALUES ($1, $2, $3, $4) RETURNING *`;
        const values = [title, body, date, uuid];
        const result = await db.query(sql, values);
        return result.rows[0];
    },

    async getPostByUUID(uuid) {
        const sql = `SELECT * FROM posts WHERE uuid = $1`;
        const result = await db.query(sql, [uuid]);
        return result.rows[0];
    },

    async updatePostByUUID(uuid, updatedPost) {
        const { title, body, date } = updatedPost;
        const sql = `UPDATE posts SET title = $1, body = $2, date = $3 WHERE uuid = $4 RETURNING *`;
        const values = [title, body, date, uuid];
        const result = await db.query(sql, values);
        return result.rows[0];
    },

    async deletePostByUUID(uuid) {
        const sql = `DELETE FROM posts WHERE uuid = $1 RETURNING *`;
        const result = await db.query(sql, [uuid]);
        return result.rows[0];
    }


};*/