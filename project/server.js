const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const router = express.Router();


const app = express();
app.use(cors());
app.use(express.json());

const loginRouter = require('./routes/login.js');
const authorize = require('./routes/authorize.js');
const booksRouter = require('./routes/books.js'); 
const registerRouter = require('./routes/register.js');
const menuRouter = require('./routes/menu.js');

// Serve static files - unprotected
app.use(express.static(path.join(__dirname, 'client')));

// Protected route for manage_books.html
app.get('/Wproject/client/manage_books.html', authorize, (req, res) => {
  res.sendFile(path.join(__dirname, 'client', 'manage_books.html'));
});

app.use('/', booksRouter);
app.use('/login', loginRouter);
app.use('/register', registerRouter);
app.use('/api', authorize);
app.use('/api/menu',authorize, menuRouter);



app.get('/pleaseLogin', (req, res) => {
    console.log('pleaseLogin');
    res.sendFile(path.join(__dirname, 'client/index.html'));
});



const PORT = process.env.PORT || 5500;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
