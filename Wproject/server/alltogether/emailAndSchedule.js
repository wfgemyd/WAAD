require('dotenv').config();
const jwt = require("jsonwebtoken");
const router = require('express').Router();
const db = require('./postgres');
const cron = require('node-cron');



// Scheduled task to run every day at 3 AM
cron.schedule('0 3 * * *', async () => { // 3:00 AM daily
    console.log('Running scheduled task to update ticket status...');
    await updateTicketStatus();
});
// Function to update ticket status from verifying to closed after 14 days
async function updateTicketStatus() {
    try {
        // Call your PostgreSQL function
        await db.query('SELECT Fproject.update_ticket_status()');
        console.log('Ticket status updated successfully.');
    } catch (err) {
        console.error('Error executing update_ticket_status function:', err);
    }
}


cron.schedule('0 8 * * *', () => { // 8:00 AM daily
    // Your task to send emails
    console.log('Sending daily tickets email to client...');
    sendDailyTicketsEmail().then(r => console.log('Email sent successfully')).catch(e => console.error('Error sending email:', e));
});


const nodemailer = require('nodemailer');
const path = require("path");

async function getTicketCountForClient(userId) {
    let openAndVerifiedTickets;
    try {
        const result = await db.query('SELECT * FROM Fproject.get_user_tickets($1)', [userId]);
        openAndVerifiedTickets = result.rows.filter(ticket => ticket.status_name === 'Open' || ticket.status_name === 'Verifying');

        return openAndVerifiedTickets;
    } catch (error) {
        console.error('Failed to fetch tickets:', error);
    }
}
async function sendDailyTicketsEmail() {
    // Example: Fetch the number of tickets from your database
    const userId = await db.query('SELECT id FROM Fproject.user');


    for (let ids of userId.rows) {
        const ticketCount = (await getTicketCountForClient(ids.id)).sort((a, b) => a.status_name - b.status_name);
        const userEmailAddress = await db.query('SELECT email FROM Fproject.user WHERE id = $1', [ids.id]);
    // Generate HTML table
        let tableHtml = `
  <table style="width: 100%; border-collapse: collapse; font-family: Arial, sans-serif;">
    <tr style="background-color: #f2f2f2;">
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Ticket Status</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Ticket ID</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">WBI</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Subject</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Category</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Requester Name</th>
      <th style="padding: 12px; text-align: left; border-bottom: 1px solid #ddd;">Requester Position</th>
    </tr>
`;

        ticketCount.forEach((ticket, index) => {
            const rowStyle = index % 2 === 0 ? 'background-color: #f9f9f9;' : '';
            tableHtml += `
    <tr style="${rowStyle}">
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.status_name}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.ticket_id}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.wbi}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.subject}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.category_name}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.requester_name}</td>
      <td style="padding: 12px; border-bottom: 1px solid #000000;">${ticket.requester_position}</td>
    </tr>
  `;
        });

        tableHtml += '</table>';

    // Set up transporter
    // Set up transporter using a test SMTP service
    const transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        auth: {
            user: 'lenna.kohler72@ethereal.email', // generated ethereal user
            pass: 'zARaTywtJy1e5FYVFf' // generated ethereal password
        }
    });

    // Send email
    const info = await transporter.sendMail({
        from: '"Your Website" <lenna.kohler72@ethereal.email>', // sender address
        to: userEmailAddress.rows[0].email, // should be fetched from the user and used per user, this will send the relevant tickets to relevant users.
        subject: `Daily Tickets Update`,
        html: `<p>Here is the daily ticket update:</p>${tableHtml}
       <p>For more information, please visit: <a href="http://localhost:3000/tickets">Ticket Dashboard</a></p>
       <p>Thank you for using our service.</p>`,
    });

    console.log(`Message sent: %s to %s` , info.messageId, ids.id);
    console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

    }
}
//https://ethereal.email/create
//sendDailyTicketsEmail().then(r => console.log('Email sent successfully')).catch(e => console.error('Error sending email:', e));


// Scheduled task to run every 5 minutes
cron.schedule('*/5 * * * *', async () => {
    console.log('Running scheduled task to update new notifications...');
    await newNotifications();
});

async function newNotifications(userId, io) {
    try {
        const result = await db.query('SELECT * FROM Fproject.notifications WHERE user_id = $1 AND read = false', [userId]);

        if (result.rows.length > 0) {
            // Emit a WebSocket event to the specific user
            io.to(userId).emit('new-notification');
        }
        console.log('Notifications checked successfully.');
    } catch (err) {
        console.error('Error retrieving new notifications:', err);
    }
}

module.exports = {router: router, newNotifications: newNotifications};