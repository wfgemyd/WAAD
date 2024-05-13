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

        fetchBooks() {
            fetch('http://localhost:5500/books')
                .then(response => response.json())
                .then(data => {
                    this.books = data;
                })
                .catch(error => console.error('Error fetching books:', error));
        },

        submitForm() {
            const url = this.form.id ? `http://localhost:5500/api/menu/books/${this.form.id}` : 'http://localhost:5500/api/menu/books';
            const method = this.form.id ? 'PUT' : 'POST';

            fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(this.form)
            })
            .then(response => response.json())
            .then(() => {
                this.fetchBooks();
                this.form = { id: '', title: '', publication_year: '', isbn: '', author: '', genre: '' }; // Reset form
            })
            .catch(error => console.error('Error submitting form:', error));
        },

        editBook(book) {
            this.form = { ...book };
        },

        deleteBook(id) {
            fetch(`http://localhost:5500/api/menu/books/${id}`, {
                method: 'DELETE'
            })
            .then(() => {
                this.fetchBooks(); // Refresh the list after deletion
            })
            .catch(error => console.error('Error deleting book:', error));
        }
    };
}
