const bookListComponent = () => {
    return {
        loading: true,
        books: [],
        async fetchBooks() {
            try {
                const response = await fetch('/api/books');
                this.books = await response.json();
            } catch (error) {
                console.error('Error fetching books:', error);
            } finally {
                this.loading = false;
            }
        },
        init() {
            this.fetchBooks();
        }
    }
}