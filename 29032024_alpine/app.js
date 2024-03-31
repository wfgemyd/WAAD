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
    Alpine.data('foo', () => ({
    myData: 'Hello World!',
   
    init() {
    console.log('init');
    },
    changeData() {
    this.myData = 'Hello Alpine.js!';
    }
    }));
   });

/*
document.addEventListener('alpine:init', () => {
Alpine.data('foo', () => ({
myData: 'Hello World!',
buttonVisible: true, // This controls the visibility

init() {
console.log('init');
},
changeData() {
this.myData = 'Hello Alpine.js!';
},
toggleButtonVisibility() {
this.buttonVisible = !this.buttonVisible; // Toggle the visibility
}
}));
});*/

document.addEventListener('alpine:init', () => {
    Alpine.data('foo', () => ({
    myData: 'Hello World!',
    items: [], // Array to store list items
    newItem: '', // Bound to the input field for new items
   
    init() {
    console.log('init');
    },
    changeData() {
    this.myData = 'Hello Alpine.js!';
    },
    addItem() {
     if (this.newItem.trim() !== '') {
      this.items.push(this.newItem); // Add the new item to the array
      this.newItem = ''; // Clear the input field
     }
    }
    }));
   });
   

document.addEventListener('alpine:init', () => {
Alpine.data('counter', () => ({
    count: 0, // Initial counter value

    increment() {
    this.count += 1; // Increment the counter
    },

    decrement() {
    if (this.count > 0) {
    this.count -= 1; // Decrement the counter only if it's above 0
    }
    }
}));
});