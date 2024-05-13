require('dotenv').config();
const router = require('express').Router();
const db = require('./postgres');

//get the list for the onboarding checklist
router.get('/', async (req, res) => {

    try {
    const sql = `
        SELECT checklist_item.id, checklist_item.item_description
        FROM fproject.checklist_item checklist_item
                 JOIN fproject.checklist_template_item checklist_template_item ON checklist_item.id = checklist_template_item.checklist_item_id
                 JOIN fproject.checklist_template checklist_template ON checklist_template_item.checklist_template_id = checklist_template.id
        WHERE checklist_template.checklist_name = 'Onboarding Checklist'
        `;
    const result = await db.query(sql);
    if (result.rowCount) {
        res.json(result.rows);
    } else {
        res.status(404).json({ message: 'No checklist items found' });
    }
} catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
}
});

// Update the user's checklist status when the checklist is submitted
router.post('/submit', async (req, res) => {
    const { userId, checkedItems } = req.body;
    try {
        // Update the user's checklist status in the database
        const updateSql = `
      INSERT INTO fproject.user_checklist_status (user_id, checklist_item_id, is_completed, completed_at)
      VALUES ($1, $2, TRUE, CURRENT_TIMESTAMP)
      ON CONFLICT (user_id, checklist_item_id) DO UPDATE SET is_completed = TRUE, completed_at = CURRENT_TIMESTAMP
    `;
        for (const itemId of checkedItems) {
            await db.query(updateSql, [userId, itemId]);
        }
        res.status(200).json({ message: 'Checklist submitted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;