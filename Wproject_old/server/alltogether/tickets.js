require('dotenv').config();
const router = require('express').Router();
const db = require('./postgres');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const path = require('path');


router.get('/', async (req, res) => {
    try {
        const userId = req.user.uId;
        const result = await db.query('SELECT * FROM Fproject.get_user_tickets($1)', [userId]);

        // Process each ticket to include attachment details
        const ticketsWithAttachments = result.rows.map(ticket => {
            // Check if the ticket includes an attachment
            if (ticket.attachment) {
                // Assuming attachment data is already in base64 or you convert it here
                const attachmentType = ticket.attachment_type || path.extname(ticket.attachment_name).slice(1);
                ticket.attachment = {
                    data: ticket.attachment.toString('base64'),
                    type: ticket.attachment_type === 'png' ? 'image/png' : attachmentType,
                    name: ticket.attachment_name
                };
            } else {
                // Ensure attachment is null if not present
                ticket.attachment = null;
            }
            return ticket;
        });

        res.json(ticketsWithAttachments);
    } catch (error) {
        console.error('Failed to fetch tickets:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.get('/:ticketId/details', async (req, res) => {
    try {
        const { ticketId } = req.params;
        const ticketDetails = await db.query('SELECT * FROM Fproject.ticket WHERE id = $1', [ticketId]);
        const ticketComments = await db.query(`
            SELECT tc.*, u.f_name, u.l_name
            FROM Fproject.ticket_comment tc
                     JOIN Fproject."user" u ON tc.user_id = u.id
            WHERE tc.ticket_id = $1
            ORDER BY tc.created_at
        `, [ticketId]);
        const ticketEvents = await db.query('SELECT * FROM Fproject.event_store WHERE aggregate_id = $1', [ticketId]);
        // Convert attachment data to base64
        const commentsWithAttachments = ticketComments.rows.map(comment => {
            if (comment.attachment) {
                const attachmentType = comment.attachment_type || path.extname(comment.attachment_name).slice(1);

                comment.attachment = {
                    data: comment.attachment.toString('base64'),
                    type: attachmentType === 'png' ? 'image/png' : attachmentType,
                    name: comment.attachment_name,
                };
            }
            return comment;
        });

        res.json({
            ticket: ticketDetails.rows[0],
            comments: commentsWithAttachments,
            events: ticketEvents.rows
        });
    } catch (error) {
        console.error('Failed to fetch ticket details:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});




router.post('/:ticketId/comment', upload.single('attachment'), async (req, res) => {
    try {
        const { ticketId } = req.params;
        const { userId, comment } = req.body;
        const attachment = req.file ? req.file.buffer : null;
        const attachmentName = req.file ? req.file.originalname : null; // Get the original file name
        const attachmentType = req.file ? req.file.mimetype : null;
        console.log('file comment:', attachment);

        await db.query('SELECT Fproject.add_ticket_comment($1, $2, $3, $4, $5, $6)', [ticketId, userId, comment, attachment, attachmentName, attachmentType]);
        res.json({ message: 'Comment added successfully' });
    } catch (error) {
        console.error('Failed to add comment:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});



router.get('/options', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM Fproject.get_ticket_options()');
        const options = result.rows.reduce((acc, row) => {
            if (!acc[row.option_type]) {
                acc[row.option_type] = {};
            }
            acc[row.option_type][row.option_value] = row.option_label;
            return acc;
        }, {});
        res.json(options);
    } catch (error) {
        console.error('Failed to fetch ticket options:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});


router.put('/:id', async (req, res) => {
    try {
        const ticketId = parseInt(req.params.id, 10); // Cast to integer
        const updatedTicket = req.body;
        console.log(updatedTicket);
        const userId = parseInt(req.user.uId, 10); // Cast to integer


        // Start a transaction
        await db.query('BEGIN');

        // Update the ticket fields
        //await db.query(`
        //    UPDATE Fproject.ticket
        //    SET updated_at = CURRENT_TIMESTAMP
        //    WHERE id = $1
        //`, [ticketId]);

// Call the UpdateTicket stored procedure with the user ID
        console.log(ticketId, userId, updatedTicket.status_name, updatedTicket.priority_name, updatedTicket.assigned_to_name, null, updatedTicket.category_name, null, null, true, updatedTicket.permission_required, updatedTicket.requester_position);
        await db.query('CALL Fproject.UpdateTicket($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)', [
            ticketId,
            userId,
            updatedTicket.status_name,
            updatedTicket.priority_name,
            updatedTicket.assigned_to_name,
            null, // p_new_fallback_approver_name
            updatedTicket.category_name,
            null, // p_comment
            null, // p_file_data
            true, // p_is_manager_or_admin
            updatedTicket.requester_position, // p_new_position_name
            updatedTicket.permission_required // p_new_permission_name
        ]);
// Update the ticket priority
        if (updatedTicket.priority_name) {
            const priorityResult = await db.query(`
        SELECT id FROM Fproject.ticket_priorities WHERE priority_name = $1
    `, [updatedTicket.priority_name]);
            const priorityId = parseInt(priorityResult.rows[0].id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET priority_id = $1 WHERE id = $2
    `, [priorityId, ticketId]);
        }

// Update the assigned user
        if (updatedTicket.assigned_to_name) {
            const assignedToResult = await db.query(`
        SELECT id FROM Fproject."user" WHERE CONCAT(f_name, ' ', l_name) = $1
    `, [updatedTicket.assigned_to_name]);
            const assignedToId = parseInt(assignedToResult.rows[0].id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET assigned_to = $1 WHERE id = $2
    `, [assignedToId, ticketId]);
        }

// Update the ticket category
        if (updatedTicket.category_name) {
            const categoryResult = await db.query(`
        SELECT category_id FROM Fproject.categories WHERE category_name = $1
    `, [updatedTicket.category_name]);
            const categoryId = parseInt(categoryResult.rows[0].category_id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET category_id = $1 WHERE id = $2
    `, [categoryId, ticketId]);
        }

// Update the permission required
        if (updatedTicket.permission_required) {
            const permissionResult = await db.query(`
        SELECT id FROM Fproject.permissions WHERE permission_name = $1
    `, [updatedTicket.permission_required]);
            const permissionId = parseInt(permissionResult.rows[0].id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET permission_required = $1 WHERE id = $2
    `, [permissionId, ticketId]);
        }

// Update the role required
        if (updatedTicket.requester_position) {
            const positionResult = await db.query(`
        SELECT id FROM Fproject.position WHERE pos_name = $1
    `, [updatedTicket.requester_position]);
            const positionId = parseInt(positionResult.rows[0].id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET requested_position = $1 WHERE id = $2
    `, [positionId, ticketId]);
        }

// Update the ticket status
        if (updatedTicket.status_name) {
            const statusResult = await db.query(`
        SELECT id FROM Fproject.ticket_status WHERE status_name = $1
    `, [updatedTicket.status_name]);
            const statusId = parseInt(statusResult.rows[0].id, 10); // Cast to integer
            await db.query(`
        UPDATE Fproject.ticket SET status_id = $1 WHERE id = $2
    `, [statusId, ticketId]);
        }

        // Commit the transaction
        await db.query('COMMIT');

        res.sendStatus(200);
    } catch (error) {
        // Rollback the transaction if an error occurs
        await db.query('ROLLBACK');
        console.error('Failed to update ticket:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.delete('/:ticketId/:userId', async (req, res) => {
    try {
        const { ticketId } = req.params;
        const { userId } = req.params;
        await db.query('CALL Fproject.CloseOrDeleteTicket($1, $2)', [parseInt(ticketId,10), parseInt(userId, 10)] );
        res.json({ message: 'Ticket deleted successfully' });
    }
    catch (error) {
        console.error('Failed to delete ticket:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
