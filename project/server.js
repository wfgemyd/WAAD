const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const router = express.Router();


const app = express();
app.use(cors());
app.use(express.json());

const loginRouter = require('./routes/login.js');
const authorizeRouter = require('./routes/authorize.js');
const booksRouter = require('./routes/books.js'); 
const registerRouter = require('./routes/register.js');
const menuRouter = require('./routes/menu.js');


app.use(express.static(path.join(__dirname, 'Wproject')));



app.use('/', booksRouter);
app.use('/login', loginRouter);
app.use('/register', registerRouter);
app.use('/api', authorizeRouter);
app.use('/api/menu',authorizeRouter, menuRouter);



app.get('/pleaseLogin', (req, res) => {
    res.sendFile(path.join(__dirname, 'client/dist/index.html'));
});



const PORT = process.env.PORT || 5500;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
