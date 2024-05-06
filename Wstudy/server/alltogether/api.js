const router = require('express').Router();

router.get('/hello', (req, res) => {
    res.json(["Hello!"]);
});

module.exports = router;