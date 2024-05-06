/*
Basically the routes.js file is responsible for defining and exporting the API routes/endpoints for the application.
These routes use the methods defined in the model.js file to perform CRUD operations on
 the posts table in the database.


const model = require('./model');
const router = require('express').Router();

router.post('/posts', async (req, res) => {
    try {
        const newPost = req.body;
        const createdPost = await model.createPost(newPost);
        res.status(201).json(createdPost);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error creating a new post' });
    }
});

router.get('/posts', async (req, res) => {
    try {
        const posts = await model.getPosts();
        res.json(posts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching posts' });
    }
});

router.get('/posts/:uuid', async (req, res) => {
    try {
        const uuid = req.params.uuid;
        const post = await model.getPostByUUID(uuid);
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        res.json(post);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching post by UUID' });
    }
});

router.put('/posts/:uuid', async (req, res) => {
    try {
        const uuid = req.params.uuid;
        const updatedPost = req.body;
        const updated = await model.updatePostByUUID(uuid, updatedPost);
        if (!updated) {
            return res.status(404).json({ message: 'Post not found' });
        }
        res.json(updated);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error updating post by UUID' });
    }
});

router.delete('/posts/:uuid', async (req, res) => {
    try {
        const uuid = req.params.uuid;
        const deletedPost = await model.deletePostByUUID(uuid);
        if (!deletedPost) {
            return res.status(404).json({ message: 'Post not found' });
        }
        res.json(deletedPost);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error deleting post by UUID' });
    }
});

module.exports = router;


*/

/* Purpose: Defines API routes/endpoints for the application.
Key Components:
router.get('/users', ...) : An Express route that handles GET requests to /api/
users . It uses the model.getUsers() function to retrieve users from the database and
sends the users as a JSON response. Error handling is included to respond with a 400 status
code if an error occurs.
*/