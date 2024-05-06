require('dotenv').config();
const router = require('express').Router();
const db = require('./postgres');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const path = require('path');



router.post('/:userId/new_ticket',upload.any(), async (req, res) => {
    const userId = parseInt(req.params.userId);
    const attachment = req.files[0] ? req.files[0].buffer : null;
    const attachment_name = req.files[0] ? req.files[0].originalname : null; // Get the original file name
    const attachment_type = req.files[0] ? req.files[0].mimetype : null;
    console.log('req.file:', req.file, req.files[0]);
    console.log('files:', attachment);
    console.log('files name:', attachment_name);
    console.log('files type:', attachment_type);


    if (isNaN(userId)) {
        return res.status(400).json({ error: 'Invalid user ID' });
    }
    const {
        subject,
        content,
        status_name,
        priority_name,
        category_name,
        requested_position,
        manager_wbi,
        permission_required_name,
    } = req.body;

    try {
        // Call the stored procedure with all parameters
        const result = await db.query('CALL Fproject.CreateTicket($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)', [
            subject,
            content,
            status_name,
            priority_name,
            parseInt(userId),
            manager_wbi,
            category_name,
            attachment,
            permission_required_name,
            requested_position,
            attachment_name,
            attachment_type,
        ]);

        if (result.rows[0]) {
            res.status(201).json({ message: 'Ticket created successfully', ticketId: result.rows[0].id });
        } else {
            res.status(201).json({ message: 'Ticket created successfully' });
        }
    } catch (error) {
        console.error('Failed to create ticket:', error);
        res.status(500).json({ error: 'Failed to create ticket' });
    }
});



router.get('/:categoryName/manager', async (req, res) => {
    try {
        const { categoryName } = req.params;

        // Step 1: Find the category ID from the category name
        const categoryResult = await db.query(`
            SELECT category_id FROM Fproject.categories WHERE category_name = $1
        `, [categoryName]);

        if (categoryResult.rows.length === 0) {
            return res.status(404).json({ error: 'Category not found' });
        }

        const categoryId = categoryResult.rows[0].category_id;

        // Step 2: Find the role IDs for 'Manager' and 'Administrator'
        const rolesResult = await db.query(`
            SELECT id, role_name FROM Fproject.role WHERE role_name IN ('Manager', 'Administrator')
        `);

        const roles = rolesResult.rows.reduce((acc, role) => {
            acc[role.role_name] = role.id;
            return acc;
        }, {});

        // Step 3: Find users in the specified category with 'Manager' role
        const managersResult = await db.query(`
            SELECT u.id, u.f_name, u.l_name, r.role_name, u.wbi
            FROM Fproject."user" u
            JOIN Fproject.user_categories uc ON u.id = uc.user_id
            JOIN Fproject.role r ON u.role_id = r.id
            WHERE uc.category_id = $1 AND r.id = $2
        `, [categoryId, roles['Manager']]);

        let selectedUser = managersResult.rows[0];

        if (!selectedUser) {
            // Step 4: If no manager is found, find an administrator
            const administratorsResult = await db.query(`
                SELECT u.id, u.f_name, u.l_name, r.role_name, u.wbi
                FROM Fproject."user" u
                JOIN Fproject.role r ON u.role_id = r.id
                WHERE r.id = $1
            `, [roles['Administrator']]);

            selectedUser = administratorsResult.rows[0];
        }

        if (!selectedUser) {
            return res.status(404).json({ error: 'No manager or administrator found for the selected project' });
        }

        res.json({
            id: selectedUser.id,
            name: `${selectedUser.f_name} ${selectedUser.l_name}`,
            role: selectedUser.role_name,
            wbi: selectedUser.wbi
        });
    } catch (error) {
        console.error('Failed to fetch project manager:', error);
        res.status(500).json({ error: 'Failed to fetch project manager' });
    }
});



module.exports = router;
