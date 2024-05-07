const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const books = [
  { id: 1, title: 'Book One', author: 'Author One', genre: 'Fiction' },
  { id: 2, title: 'Book Two', author: 'Author Two', genre: 'Non-Fiction' },
  { id: 3, title: 'Book Three', author: 'Author Three', genre: 'Fiction' },
  { id: 4, title: 'Book Four', author: 'Author Four', genre: 'Non-Fiction' },
  { id: 5, title: 'Book Five', author: 'Author Five', genre: 'Adult'},
  { id: 6, title: 'Book Six', author: 'Author Six', genre: 'Non-Fiction'},
  { id: 7, title: 'Book Seven', author: 'Author Seven', genre: 'Fiction'},
  { id: 8, title: 'Book Eight', author: 'Author Eight', genre: 'Non-Fiction'},
  { id: 9, title: 'Book Nine', author: 'Author Nine', genre: 'Fiction'},
  { id: 10, title: 'Book Ten', author: 'Author Ten', genre: 'Action'}
  
  // Add more books as needed
];

// Endpoint to get books
app.get('/books', (req, res) => {
  const { genre, author, title, id } = req.query; 
  let filteredBooks = books;

  if (id) {
    const numericId = parseInt(id, 10); // Convert id from string to integer
    if (!isNaN(numericId)) { // Check if the conversion was successful
      filteredBooks = filteredBooks.filter(book => book.id === numericId);
    }
  }
 
  if (genre) {
    filteredBooks = filteredBooks.filter(book => book.genre.toLowerCase().includes(genre.toLowerCase()));
  }
  if (author) {
    filteredBooks = filteredBooks.filter(book => book.author.toLowerCase().includes(author.toLowerCase()));
  }
  if (title) {
    filteredBooks = filteredBooks.filter(book => book.title.toLowerCase().includes(title.toLowerCase()));
  }

  res.json(filteredBooks);
});

// New endpoint to get unique genres
app.get('/genres', (req, res) => {
  const uniqueGenres = [...new Set(books.map(book => book.genre))];
  res.json(uniqueGenres);
});

// New endpoint to get unique authors
app.get('/authors', (req, res) => {
  const uniqueAuthors = [...new Set(books.map(book => book.author))];
  res.json(uniqueAuthors);
});

// New endpoint to get unique titles
app.get('/titles', (req, res) => {
  const uniqueTitles = [...new Set(books.map(book => book.title))];
  res.json(uniqueTitles);
});


const PORT = process.env.PORT || 5500;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
