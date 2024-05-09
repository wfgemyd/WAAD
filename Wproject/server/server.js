const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const loginRouter = require('./login.js');
const authorizeRouter = require('./authorize.js');
const booksRouter = require('./books.js'); // Assuming you refactor books.js to use Router

app.use('/', booksRouter);
app.use('/login', loginRouter);
app.use('/api', authorizeRouter);


app.get('/pleaseLogin', (req, res) => {
    res.sendFile(path.join(__dirname, 'client/dist/index.html'));
});

const PORT = process.env.PORT || 5500;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
