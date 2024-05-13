const router = require('express').Router();
const db = require('./postgres'); // Ensure this path correctly points to your database connection module

// Endpoint to get books with optional filtering
router.get('/books', async (req, res) => {
  try {
    const { genre, author, title, id } = req.query;

    // Construct the base query
    let query = `
      SELECT b.id, b.title, a.full_name AS author, g.name AS genre
      FROM books b
      JOIN authors a ON b.author_id = a.id
      JOIN genres g ON b.genre_id = g.id
    `;

    // Add WHERE clauses based on query parameters
    const conditions = [];
    const params = [];

    if (id) {
      conditions.push(`b.id = $${conditions.length + 1}`);
      params.push(id);
    }
    if (genre) {
      conditions.push(`LOWER(g.name) LIKE LOWER($${conditions.length + 1})`);
      params.push(`%${genre}%`);
    }
    if (author) {
      conditions.push(`LOWER(a.full_name) LIKE LOWER($${conditions.length + 1})`);
      params.push(`%${author}%`);
    }
    if (title) {
      conditions.push(`LOWER(b.title) LIKE LOWER($${conditions.length + 1})`);
      params.push(`%${title}%`);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    const { rows } = await db.query(query, params);
    res.json(rows);
  } catch (error) {
    console.error('Failed to fetch books:', error);
    res.status(500).json({ message: 'Failed to fetch books' });
  }
});

// Endpoint to get unique genres
router.get('/genres', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT DISTINCT name AS genre FROM genres ORDER BY genre');
    res.json(rows.map(row => row.genre));
  } catch (error) {
    console.error('Failed to fetch genres:', error);
    res.status(500).json({ message: 'Failed to fetch genres' });
  }
});

// Endpoint to get unique authors
router.get('/authors', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT DISTINCT full_name AS author FROM authors ORDER BY author');
    res.json(rows.map(row => row.author));
  } catch (error) {
    console.error('Failed to fetch authors:', error);
    res.status(500).json({ message: 'Failed to fetch authors' });
  }
});

// Endpoint to get unique titles
router.get('/titles', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT DISTINCT title FROM books ORDER BY title');
    res.json(rows.map(row => row.title));
  } catch (error) {
    console.error('Failed to fetch titles:', error);
    res.status(500).json({ message: 'Failed to fetch titles' });
  }
});

module.exports = router;
