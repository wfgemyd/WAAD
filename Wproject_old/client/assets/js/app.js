/* The event listener waits for the alpine:init event, which fires when Alpine.js is ready to
initialize.

Alpine.data('foo', () => ({...})) defines a component named foo . This name matches
the x-data attribute in your HTML. Each Alpine project can have multiple components.

Inside foo , myData is a property that holds the text displayed in your paragraph and input
elements. You can create multiple properties in each component.

The init() function runs when the component is initialized, indicated by the console log.

changeData() is a method that changes the value of myData to a new string when called,
which in turn updates the paragraph and input field thanks to Alpine's reactivity. */

document.addEventListener('alpine:init', () => {
    Alpine.data('libraryApp', () => ({
        books: [], 
        search: '',
        selectedGenre: '',
        selectedAuthor: '',
        selectedTitle: '',
        genres: [], // Add more genres as needed
        authors: [], // Add more authors as needed
        titles: [], // Add more titles as needed

        currentSort: 'title',
        currentSortDir: 'asc',


        init() {
            this.fetchGenres();
            this.fetchBooks();
            this.fetchAuthors();
            this.fetchTitles();

        },

        fetchBooks() {
            const params = new URLSearchParams({ //search by title, genre, author
                id: this.search,
                genre: this.selectedGenre,
                author: this.selectedAuthor,
                title: this.selectedTitle

            }).toString();
            fetch(`http://localhost:5500/books?${params}`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    this.books = data;
                    this.search = ''; // Clear the search input after fetching

                })
                .catch(error => {
                    console.error('Error fetching books:', error);
                });
        },
        fetchGenres() {
            fetch(`http://localhost:5500/genres`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    this.genres = data; 
                })
                .catch(error => {
                    console.error('Error fetching genres:', error);
                });
        },
        fetchAuthors() {
            fetch(`http://localhost:5500/authors`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    this.authors = data;
                })
                .catch(error => {
                    console.error('Error fetching authors:', error);
                });
        },
        fetchTitles() {
            fetch(`http://localhost:5500/titles`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    this.titles = data;
                })
                .catch(error => {
                    console.error('Error fetching titles:', error);
                });
        },

        sortBy(sortKey) {
            if (this.currentSort === sortKey) {
                this.currentSortDir = this.currentSortDir === 'asc' ? 'desc' : 'asc';
            } else {
                this.currentSort = sortKey;
                this.currentSortDir = 'asc';
            }
        },

        sortedBooks() {
            return this.books.sort((a, b) => {
                let modifier = 1;
                if (this.currentSortDir === 'desc') modifier = -1;
                if (a[this.currentSort] < b[this.currentSort]) return -1 * modifier;
                if (a[this.currentSort] > b[this.currentSort]) return 1 * modifier;
                return 0;
            });
        }
    }));
});

