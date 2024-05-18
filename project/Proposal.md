# Book Library Catalog Web Application

## Project Overview

This project aims to create a basic web application that serves as a book library catalog. The application will consist of a REST API backend and a simple frontend interface, designed to cater to two types of users with different levels of access and capabilities:

### User Types and Functionalities

1. **Reader (No Authentication Required):**
   - Public users can explore the library's collection by listing books based on genre, author, or title. No login is required to use the library catalogue.

2. **Librarian (Authentication Required):**
   - Librarians can manage books after logging in, including introducing new books to the catalog, updating existing books, and removing books that are no longer available or relevant.

## Technical Implementation

### Backend

The backend is built using Node.js and Express, with PostgreSQL as the database. It includes several key components:

- **Authorization Middleware (`authorize.js`):** Handles JWT-based user authentication, ensuring that only authenticated users can perform certain operations.
- **Database Connection (`postgres.js`):** Manages the connection to the PostgreSQL database, allowing for efficient query execution.
- **Book Management (`books.js`, `menu.js`):** Provides endpoints for fetching books, genres, authors, and titles, as well as adding, updating, and deleting books.
- **User Registration and Login (`register.js`, `login.js`):** Handles user registration, including password hashing with bcrypt, and user login, generating JWTs for authenticated sessions.

### Frontend

The frontend is developed with Alpine.js, providing a dynamic and responsive user interface. It includes:

- **Library Application (`app.js`):** Manages the state and interactions for browsing books, including fetching books, genres, authors, and titles from the backend.
- **User Authentication (`loginn.js`, `registration.js`):** Handles user login and registration, interacting with the backend to authenticate users and register new accounts.
- **Book Management (`menu.js`):** Allows librarians to add, update, and delete books, with functionalities to fetch and display books, and handle form submissions for book management.

#### Detailed Frontend Components

1. **Library Application (`app.js`):**
   - **Initialization:** Fetches genres, books, authors, and titles when the component is initialized.
   - **Fetching Data:** Methods to fetch books, genres, authors, and titles from the backend.
   - **Sorting:** Allows sorting of books by different attributes.
   - **Reactivity:** Uses Alpine.js for reactive data binding and state management.

2. **User Authentication:**
   - **Login Form (`loginn.js`):**
     - Collects username and password from the user.
     - Sends a POST request to the backend to authenticate the user.
     - Stores the received JWT token and user information in local storage upon successful login.
   - **Registration Form (`registration.js`):**
     - Collects full name, username, and password from the user.
     - Sends a POST request to the backend to register a new user.
     - Redirects to the login page upon successful registration.

3. **Book Management (`menu.js`):**
   - **Fetching Books:** Fetches the list of books from the backend, using the stored JWT token for authorization.
   - **Form Handling:** Manages the form for adding and updating books, including setting the form data and handling form submissions.
   - **Editing and Deleting Books:** Provides functionalities to edit and delete books, with appropriate authorization checks.

### Database Schema

The database schema includes tables for `authors`, `genres`, `books`, and `power_users`, with stored procedures for adding, modifying, and deleting books.

### Utilizing SASS for Styling

In the development of the Book Library Catalog Web Application, SASS (Syntactically Awesome Stylesheets) plays a pivotal role in enhancing the styling process, making it more efficient and maintainable. SASS is a preprocessor scripting language that is interpreted or compiled into Cascading Style Sheets (CSS). It introduces features that CSS lacks by nature, such as variables, nesting, mixins, inheritance, and more, which significantly improve the workflow of writing styles for the web.

#### Why SASS is a Great Choice

1. **Variables for Consistent Styling:** SASS allows the use of variables for colors, font stacks, and other values. This feature is extensively utilized in our project, as seen in the `_colors.sass`, `_fonts.sass`, and `_radius.sass` files. Variables ensure consistency across the application and make it easier to implement theme changes or adjustments.

2. **Nesting for Better Structure:** SASS nesting mimics the HTML structure, making it easier to understand and maintain the stylesheets. This is particularly useful in complex projects like ours, where maintaining readability and structure in CSS can become challenging. The nesting feature is evident in our styling for the login and menu components, where CSS rules are structured in a hierarchical manner for clarity.

3. **Modularity and Reusability:** By dividing the styles into partials (e.g., `_login.sass`, `_menu.sass`, `_colors.sass`), SASS promotes modularity. This approach allows us to reuse styles across different components, reducing redundancy and keeping the stylesheets DRY (Don't Repeat Yourself). The use of `@use` rule in `style.sass` to import styles from other SASS files demonstrates this modularity, making our codebase more organized and easier to manage.

4. **Advanced Features:** SASS offers advanced features like mixins and functions, which can be used to create complex styling patterns with minimal code. While our project primarily focuses on the basics of SASS, the potential to leverage these advanced features exists, offering scalability for future enhancements.

5. **Improved Development Experience:** With SASS, developers can write more concise and readable styles compared to plain CSS. This leads to a faster development process and easier debugging. The clear structure and organization of SASS files in our project contribute to an improved development experience, allowing team members to collaborate more effectively.

### Deployment

The application is designed for deployment on a Google Cloud Virtual Machine (VM), providing a scalable and secure hosting environment. Environment variables will be managed through `.env` files to ensure security and ease of configuration. Deploying on a Google Cloud VM allows for enhanced performance, reliability, and the flexibility to scale resources according to the application's needs.

## Project Plan

The project follows a structured plan, starting with the proposal submission and moving through setup, development, integration, testing, deployment, and documentation phases. Key milestones include backend and frontend development, integration and testing, and final review and submission.

## Conclusion

This project aims to enhance the library experience for both readers and librarians through a simple web application. By leveraging Node.js, Express, Vue.js, and PostgreSQL, it provides a user-friendly platform for book management and browsing.
