function bookApp() {
    return {
        books: [],
        form: {
            id: '',
            title: '',
            publication_year: '',
            isbn: '',
            author: '',
            genre: ''
        },
        editingBookId: null, // Track the ID of the book being edited

        fetchBooks() {
            const token = localStorage.getItem('token');
            fetch('http://localhost:5500/books', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            })
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else {
                    throw new Error('Unauthorized');
                }
            })
            .then(data => {
                this.books = data;
            })
            .catch(error => {
                console.error('Error fetching books:', error);
                if (error.message === 'Unauthorized') {
                    window.location.href = '/Wproject/client/pleaseLogin.html';
                }
            });
        },


        submitForm() {
            const token = localStorage.getItem('token');
            const url = this.form.id ? `http://localhost:5500/api/menu/books/${this.form.id}` : 'http://localhost:5500/api/menu/books';
            const method = this.form.id ? 'PUT' : 'POST';

            fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(this.form)
            })
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else {
                    throw new Error('Unauthorized');
                }
            })
            .then(() => {
                this.fetchBooks();
                this.form = { id: '', title: '', publication_year: '', isbn: '', author: '', genre: '' };
                this.editingBookId = null;
            })
            .catch(error => {
                console.error('Error submitting form:', error);
                if (error.message === 'Unauthorized') {
                    window.location.href = '/Wproject/client/pleaseLogin.html';
                }
            });
        },

        editBook(book) {
            this.form = { ...book };
            this.editingBookId = book.id; // Set the editing book ID
        },

        deleteBook(id) {
            const token = localStorage.getItem('token');
            fetch(`http://localhost:5500/api/menu/books/${id}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            })
            .then(response => {
                if (response.ok) {
                    this.fetchBooks();
                } else {
                    throw new Error('Unauthorized');
                }
            })
            .catch(error => {
                console.error('Error deleting book:', error);
                if (error.message === 'Unauthorized') {
                    window.location.href = '/Wproject/client/pleaseLogin.html';
                }
            });
        },

        isEditing(book) {
            return this.editingBookId === book.id;
        },

        logout() {
            localStorage.clear();  // Clear all local storage
            window.location.href = '/Wproject/client/index.html';  // Redirect to the login page or home page
        },
    };
}
