require('dotenv').config();
const router = require('express').Router();
const db = require('./postgres');



// Route to add a new book
router.post('/books', async (req, res) => {
    const { title, publication_year, isbn, author, genre } = req.body;
    try {
        await db.query("CALL add_book($1, $2, $3, $4, $5)", [title, publication_year, isbn, author, genre]);
        res.status(201).send({ message: "Book added successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).send({ message: "Error adding book" });
    }
});

// Route to update a book
router.put('/books/:id', async (req, res) => {
    const { id } = req.params;
    const { title, publication_year, isbn, author, genre } = req.body;
    try {
        await db.query("CALL modify_book($1, $2, $3, $4, $5, $6)", [id, title, publication_year, isbn, author, genre]);
        res.status(200).send({ message: "Book updated successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).send({ message: "Error updating book" });
    }
});

// Route to delete a book
router.delete('/books/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await db.query("CALL delete_book($1)", [id]);
        res.status(200).send({ message: "Book deleted successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).send({ message: "Error deleting book" });
    }
});

module.exports = router;

