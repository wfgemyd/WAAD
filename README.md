# Book Library Catalog Web Application https://github.com/wfgemyd/WAAD/tree/main

## Project Overview

This project is a web-based Library Management System that allows users to browse books and librarians to manage the library's catalog. The system is built using Express.js for the backend and Vue.js with Alpine.js for the frontend. The application is designed to be deployed on a Google Cloud Virtual Machine (VM), providing a scalable and secure hosting environment.

## Features

- **User Authentication:** Users can log in as readers or librarians.
- **Book Browsing:** Readers can browse books by genre, author, or title without the need to log in.
- **Book Management:** Librarians can add new books, update existing books, and delete books from the catalog.

## Installation

To set up the project, follow these steps:

### In the project folder:

**In the project folder:**

npm install

npm install express

npm install body-parser

npm install dotenv

npm install pg

npm install jsonwebtoken

npm install bcrypt

npm install -g nodemon

npm install multer

npm install path

npm install concurrently --save-dev


**In the client folder:**

npm install

npm install axios

npm install vue-router@next

npm install sass-loader sass --save-dev

npm install multer

npm install path

## Application Architecture

### Backend

The backend is built using Node.js and Express, with PostgreSQL as the database. Key components include:
Authorization Middleware (authorize.js): Handles JWT-based user authentication, ensuring that only authenticated users can perform certain operations.
Database Connection (postgres.js): Manages the connection to the PostgreSQL database, allowing for efficient query execution.
Book Management (books.js): Provides endpoints for fetching books, genres, authors, and titles, as well as adding, updating, and deleting books.
User Registration and Login (register.js, login.js): Handles user registration, including password hashing with bcrypt, and user login, generating JWTs for authenticated sessions.

### Frontend

The frontend is developed with Vue.js and Alpine.js, providing a dynamic and responsive user interface. Key components include:
Library Application (app.js): Manages the state and interactions for browsing books, including fetching books, genres, authors, and titles from the backend.
User Authentication (loginn.js, registration.js): Handles user login and registration, interacting with the backend to authenticate users and register new accounts.
Book Management (menu.js): Allows librarians to add, update, and delete books, with functionalities to fetch and display books, and handle form submissions for book management.

### Utilizing SASS for Styling

SASS (Syntactically Awesome Stylesheets) is used to enhance the styling process, making it more efficient and maintainable. SASS introduces features such as variables, nesting, mixins, and inheritance, which significantly improve the workflow of writing styles for the web.

#### Why SASS is a Great Choice
Variables for Consistent Styling: SASS allows the use of variables for colors, font stacks, and other values, ensuring consistency across the application.
Nesting for Better Structure: SASS nesting mimics the HTML structure, making it easier to understand and maintain the stylesheets.
Modularity and Reusability: By dividing the styles into partials, SASS promotes modularity, allowing for reuse across different components.
Advanced Features: SASS offers advanced features like mixins and functions, which can be used to create complex styling patterns with minimal code.
Improved Development Experience: SASS leads to a faster development process and easier debugging, contributing to an improved development experience.

## Deployment

The application is designed for deployment on a Google Cloud Virtual Machine (VM), providing a scalable and secure hosting environment. Environment variables are managed through .env files to ensure security and ease of configuration. 
http://34.82.179.167:5500

## Development Process

### **Initial Setup**

Set up the development environment.

Configure the backend with Node.js, Express, and PostgreSQL.

Set up the frontend with Vue.js and Alpine.js.

### **Backend Development**

Implement REST API endpoints for managing books, genres, authors, and titles.

Implement authentication and authorization mechanisms.

### **Frontend Development**

Develop the user interface for browsing books (Reader functionality).

Develop the user interface for managing books (Librarian functionality).

### **Integration and Testing**

Integrate the frontend with the backend.

Perform unit testing and integration testing.

Conduct user acceptance testing.

### **Deployment and Documentation**

Deploy the application to a Google Cloud VM.

Prepare and submit project documentation, including user manuals and API documentation.


## Critical Evaluation

### Successes

- **User Authentication:** Successfully implemented secure JWT-based authentication for librarians.

- **Book Management:** Provided comprehensive CRUD operations for book management.

- **Responsive UI:** Developed a responsive and user-friendly interface using Vue.js and Alpine.js.

- **Consistent Styling:** Utilized SASS for consistent and maintainable styling across the application.


### Challenges

- **Authentication:** Ensuring secure and efficient authentication was challenging but successfully implemented using JWT.

- **Data Fetching:** Managing asynchronous data fetching and state management required careful planning and implementation.

- **Styling:** Maintaining consistent styling across different components was addressed by using SASS variables and modular partials.


### Explanation of Design Choices

In the development of this project, which utilizes Alpine.js, Express.js, and PostgreSQL, I made a conscious decision to load all the book data at once in the select form elements. This design choice was made as a demonstration of the concept of API interaction, rather than for a practical, large-scale implementation.


### Rationale for Loading All Data at Once

For the proof of concept, I wanted to ensure that the user would have a comfortable browsing experience, with the ability to easily navigate and select from the available books. By loading all the data upfront, the user can quickly and seamlessly interact with the application, without the need for additional page loads or pagination.


### Considerations for Larger Datasets

I acknowledge that in a real-world scenario with a larger library, such as 50,000 books, loading all the data at once may not be the most practical approach. In such cases, implementing pagination or lazy loading techniques would be more appropriate to optimize performance and provide a smooth user experience.


### Spaghetti Code Approach

Due to the size and scope of the project, the codebase was not divided into smaller, more manageable chunks, as is typically recommended in the industry. This "spaghetti code" approach was chosen to make the project easier to debug and maintain during the proof-of-concept stage.
I understand that in a production-ready application, it is generally accepted best practice to modularize the codebase and follow established software engineering principles.
