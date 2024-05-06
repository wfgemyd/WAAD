const router = require('express').Router();

router.get('/inside', (req, res) => {
    res.sendFile(path.join(__dirname, 'front/inside.html'));
});

module.exports = router;