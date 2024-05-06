/*
Purpose: Serves as the entry point for the application. It initializes the Express.js server, sets up
middleware, and starts listening for requests on a specified port.

Key Components:
require('dotenv').config() : Loads environment variables from a .env file into
process.env .
express() : Creates an instance of an Express application.
express.json() : Middleware to parse JSON bodies of incoming requests.
express.static('app') : Serves static files (like HTML, CSS, JS) from the app directory.
app.use('/api', routes) : Mounts the router on the /api path. All routes defined in
routes.js will be prefixed with /api .
app.listen() : Starts the server to listen on the port specified in the .env file, logging a
message to the console when the server is ready.




Purpose: Serves as the entry point for the application, initializes the Express server, 
sets up middleware, and defines routes.
Logic Flow: It listens for incoming requests on a specified port and routes them to 
appropriate endpoints defined in routes.js.
*/


require('dotenv').config();
const express = require('express');
const app = express();
const routes = require('./routes');

app.use(express.json());
app.use('/api', routes);
app.use(express.static('app'));

const PORT = process.env.PORT || 8000; // Set a default port if PORT is not defined in .env
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
