
-- Create schema if it does not exist
CREATE SCHEMA IF NOT EXISTS Fproject;

-- Creating 'employment_status' table
CREATE TABLE Fproject.employment_status (
    id SERIAL PRIMARY KEY,
    employment_name VARCHAR
);

-- Creating 'role' table
CREATE TABLE Fproject.role (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR UNIQUE,
    role_description TEXT
);

-- Creating 'user' table
CREATE TABLE Fproject."user" (
    id SERIAL PRIMARY KEY,
    WBI VARCHAR UNIQUE NOT NULL,
    f_name VARCHAR NOT NULL,
    l_name VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    role_id INT REFERENCES Fproject.role(id), -- Foreign key to the 'role' table
    employment_status_id INT REFERENCES Fproject.employment_status(id), -- Foreign key
    password_hash VARCHAR, -- Storing the hashed password -- For Node.js, bcrypt is a good library for hashing passwords
    is_fallback_approver BOOLEAN DEFAULT FALSE -- Indicates whether the user can be assigned as a fallback approver for tickets
);

-- Creating 'department' table
CREATE TABLE Fproject.department (
    id SERIAL PRIMARY KEY,
    dep_name VARCHAR
);

-- Creating 'position' table
CREATE TABLE Fproject.position (
    id SERIAL PRIMARY KEY,
    pos_name VARCHAR
);

-- Creating 'certificates' table
CREATE TABLE Fproject.certificates (
    id SERIAL PRIMARY KEY,
    certificate_name VARCHAR,
    is_permanent BOOLEAN,
    certificate_valid_from DATE,
    certificate_valid_till DATE
);

-- Creating 'department_user' table
CREATE TABLE Fproject.department_user ( -- Many to many relationship
    department_id INT REFERENCES Fproject.department(id),
    user_id INT REFERENCES Fproject."user"(id),
    PRIMARY KEY (department_id, user_id)
);

-- Creating 'position_user' table
CREATE TABLE Fproject.position_user ( -- Many to many relationship
   position_id INT REFERENCES Fproject.position(id),
   user_id INT REFERENCES Fproject."user"(id),
    PRIMARY KEY (position_id, user_id)
);

-- Creating 'certificates_user' table
CREATE TABLE Fproject.certificates_user ( -- Many to many relationship
    certificate_id INT REFERENCES Fproject.certificates(id),
    user_id INT REFERENCES Fproject."user"(id),
    PRIMARY KEY (certificate_id, user_id)
);
------------------------------------------------------------------------------------------------

-- Checklist Templates
CREATE TABLE Fproject.checklist_template (
    id SERIAL PRIMARY KEY,
    checklist_name VARCHAR,
    role_id INT REFERENCES Fproject.role(id) -- Associating checklist with a specific role
);

-- Checklist Items
CREATE TABLE Fproject.checklist_item (
    id SERIAL PRIMARY KEY,
    item_description TEXT
);

-- Many-to-Many relationship between Checklist Templates and Checklist Items
CREATE TABLE Fproject.checklist_template_item (
    checklist_template_id INT REFERENCES Fproject.checklist_template(id),
    checklist_item_id INT REFERENCES Fproject.checklist_item(id),
    PRIMARY KEY (checklist_template_id, checklist_item_id)
);

-- User Checklist Status
CREATE TABLE Fproject.user_checklist_status (
    user_id INT REFERENCES Fproject."user"(id),
    checklist_item_id INT REFERENCES Fproject.checklist_item(id),
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL, -- Optionally track when the item was completed
    PRIMARY KEY (user_id, checklist_item_id)
);


------------------------------------------------------------------------------------------------

-- Creating 'ticket_status' table
CREATE TABLE Fproject.ticket_status ( -- One to many relationship
    id SERIAL PRIMARY KEY,
    status_name VARCHAR,
    color BIGINT,
    days_to_update INT DEFAULT NULL
);

--UPDATE Fproject.ticket_status
--SET days_to_update = 14
--WHERE status_name = 'Verifying';

-- Creating 'ticket_priorities' table
CREATE TABLE Fproject.ticket_priorities ( -- One to many relationship
    id SERIAL PRIMARY KEY,
    priority_name VARCHAR,
    color INT
);

-- Creating 'categories' table (project names)
CREATE TABLE Fproject.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR UNIQUE NOT NULL
);

-- Creating a 'permissions' table
CREATE TABLE Fproject.permissions (
                                      id SERIAL PRIMARY KEY,
                                      permission_name VARCHAR UNIQUE
);

-- Creating 'ticket' table
CREATE TABLE Fproject.ticket (
    id SERIAL PRIMARY KEY,
    subject VARCHAR,
    content TEXT,
    status_id INT REFERENCES Fproject.ticket_status(id),
    priority_id INT REFERENCES Fproject.ticket_priorities(id),
    user_id INT REFERENCES Fproject."user"(id), -- Assuming there's a 'user' table to reference
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    completed_at TIMESTAMP NULL,
    assigned_to INT REFERENCES Fproject."user"(id), --to whom the ticket is assigned
    fallback_approver INT REFERENCES Fproject."user"(id) NULL, -- If the assigned user is not available, the ticket can be assigned to a fallback approver
    category_id INT REFERENCES Fproject.categories(category_id),
    attachment BYTEA DEFAULT NULL, -- Optional: to store file data in the database;
    permission_required INT REFERENCES Fproject.permissions(id), -- The permission required to access the category
    requested_position INT REFERENCES Fproject.position(id) NULL, -- The requested position for the ticket
    attachment_name VARCHAR NULL,
    attachment_type VARCHAR NULL
);

-- Creating 'user_categories' table
CREATE TABLE Fproject.user_categories (
    user_id INT REFERENCES Fproject."user"(id),
    category_id INT REFERENCES Fproject.categories(category_id),
    permission_id INT REFERENCES Fproject.permissions(id),
    position_id INT REFERENCES Fproject.position(id), -- Update the reference to the position table
    PRIMARY KEY (user_id, category_id, permission_id, position_id)
);
ALTER TABLE Fproject.user_categories
    DROP CONSTRAINT user_categories_position_id_fkey;

ALTER TABLE Fproject.user_categories
    ADD CONSTRAINT user_categories_position_id_fkey FOREIGN KEY (position_id)
        REFERENCES Fproject.position (id);

-- Creating 'ticket_comment' table
CREATE TABLE Fproject.ticket_comment (
    id SERIAL PRIMARY KEY,
    ticket_id INT REFERENCES Fproject.ticket(id),
    user_id INT REFERENCES Fproject."user"(id), -- The user who made the comment
    comment TEXT, -- The content of the comment
    file_data BYTEA, -- adding files to the comment
    status_change INT REFERENCES Fproject.ticket_status(id), -- Optional reference to a new status
    priority_change INT REFERENCES Fproject.ticket_priorities(id), -- Optional reference to a new priority
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- The date and time when the comment was made
    attachment BYTEA DEFAULT NULL, -- Optional: to store file data in the database;
    attachment_name VARCHAR NULL,
    attachment_type VARCHAR NULL
);


-- Creating 'notifications' table
CREATE TABLE Fproject.notifications (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Fproject."user"(id),
    ticket_id INT REFERENCES Fproject.ticket(id),
    comment_id INT REFERENCES Fproject.ticket_comment(id) NULL,
    notification_type VARCHAR, -- e.g., 'status_change', 'new_comment', 'ticket_assigned'
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read BOOLEAN DEFAULT FALSE -- To track whether the notification has been read
);
CREATE TABLE Fproject.event_store (
    event_id SERIAL PRIMARY KEY,
    event_type VARCHAR NOT NULL,
    aggregate_type VARCHAR NOT NULL, -- 'ticket' for ticket-related events
    aggregate_id INT NOT NULL, -- The ticket ID to which the event relates
    payload JSON NOT NULL, -- Detailed event data (flexible structure)
    user_id INT REFERENCES Fproject."user"(id), -- The user responsible for the event
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    wbi VARCHAR REFERENCES Fproject."user"(WBI) -- The WBI of the user responsible for the event
);

CREATE TABLE Fproject.user_status (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Fproject."user"(id),
    status VARCHAR default 'Available',
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    UNIQUE(user_id, start_date, end_date) -- Ensures that there are no overlapping statuses for a user (data integrity)
);

CREATE TABLE Fproject.user_status_audit (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Fproject."user"(id),
    old_status VARCHAR,
    new_status VARCHAR,
    changed_by_user_id INT REFERENCES Fproject."user"(id),
    change_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE Fproject.ticket
    ADD CONSTRAINT ticket_attachment_size_limit
        CHECK (octet_length(attachment) <= 5242880); -- 5 MB limit

ALTER TABLE Fproject.ticket_comment
    ADD CONSTRAINT comment_attachment_size_limit
        CHECK (octet_length(attachment) <= 5242880);

ALTER TABLE fproject.ticket_comment
    DROP CONSTRAINT ticket_comment_ticket_id_fkey,
    ADD CONSTRAINT ticket_comment_ticket_id_fkey
        FOREIGN KEY (ticket_id)
            REFERENCES fproject.ticket(id)
            ON DELETE CASCADE;

---------------------------------------------------------------------------------
    -- Indexes

-- Index for searching tickets by user details
CREATE INDEX idx_user_details ON Fproject."user"(f_name, l_name);

-- Full-text search index on the ticket's content
CREATE INDEX idx_ticket_content ON Fproject.ticket USING GIN (to_tsvector('english', content));

-- Full-text search index on ticket comments
CREATE INDEX idx_ticket_comment ON Fproject.ticket_comment USING GIN (to_tsvector('english', comment));


---------------------------------------------------------------------------------
    -- Triggers
-- Trigger for updating ticket status after 14 days of "verifying" status
CREATE OR REPLACE FUNCTION Fproject.update_ticket_status()
    RETURNS TRIGGER AS $$
DECLARE
    days_to_update INT;
BEGIN
    -- Get the number of days to update from the ticket_status table
    SELECT ts.days_to_update INTO days_to_update
    FROM Fproject.ticket_status ts
    WHERE ts.id = OLD.status_id;

    -- Check if the ticket status is 'Verifying' and if the configured number of days have passed
    IF OLD.status_id = (SELECT id FROM Fproject.ticket_status WHERE status_name = 'Verifying')
        AND CURRENT_DATE - OLD.updated_at::date >= days_to_update THEN
        -- Update the ticket status to 'Closed'
        UPDATE Fproject.ticket SET status_id = (SELECT id FROM Fproject.ticket_status WHERE status_name = 'Closed')
        WHERE id = OLD.id;
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;



-- Trigger for new ticket creation
CREATE OR REPLACE FUNCTION notify_new_ticket()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Fproject.notifications (user_id, ticket_id, notification_type, message, created_at)
    VALUES (NEW.assigned_to, NEW.id, 'New Ticket', 'A new ticket has been assigned to you.', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_new_ticket
AFTER INSERT ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION notify_new_ticket();


-- Trigger for new comments in tickets
CREATE OR REPLACE FUNCTION notify_new_comment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Fproject.notifications (user_id, ticket_id, notification_type, message, created_at)
    VALUES (NEW.user_id, NEW.ticket_id, 'New Comment', 'A new comment has been added to your ticket.', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_new_comment
AFTER INSERT ON Fproject.ticket_comment
FOR EACH ROW
EXECUTE FUNCTION notify_new_comment();


-- Trigger for updating the ticket timestamp automatically on comment or status change or manager change or priority change or category change or assigned to change
CREATE OR REPLACE FUNCTION update_ticket_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Fproject.ticket SET updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ticket_on_status_change
AFTER UPDATE OF status_id ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION update_ticket_timestamp();

CREATE TRIGGER trigger_update_ticket_on_assigned_to_change
AFTER UPDATE OF assigned_to ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION update_ticket_timestamp();

CREATE TRIGGER trigger_update_ticket_on_comment
AFTER INSERT ON Fproject.ticket_comment
FOR EACH ROW
EXECUTE FUNCTION update_ticket_timestamp();

CREATE TRIGGER trigger_update_ticket_on_priority_change
AFTER UPDATE OF priority_id ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION update_ticket_timestamp();


-- Trigger for updating the ticket timestamp when the category changes
CREATE OR REPLACE FUNCTION update_ticket_timestamp_on_category_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the updated_at timestamp of the ticket when the category_id changes
    IF OLD.category_id IS DISTINCT FROM NEW.category_id THEN
        UPDATE Fproject.ticket SET updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ticket_on_category_change
AFTER UPDATE OF category_id ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION update_ticket_timestamp_on_category_change();


-- Function to check and redirect ticket assignment if the initially assigned approver is absent
CREATE OR REPLACE FUNCTION check_and_redirect_ticket()
RETURNS TRIGGER AS $$
DECLARE
    category_manager_id INT;
    approver_absent BOOLEAN;
    fallback_user_id INT;
    admin_user_id INT;
BEGIN
    -- Attempt to find a manager for the ticket's category
    -- Correctly qualifying the column names with table aliases
    SELECT u.id INTO category_manager_id
    FROM Fproject.user_categories uc
    JOIN Fproject."user" u ON uc.user_id = u.id
    JOIN Fproject.role r ON u.role_id = r.id
    WHERE uc.category_id = NEW.category_id
    AND r.role_name = 'Manager'
    AND u.is_fallback_approver = TRUE -- This condition assumes 'is_fallback_approver' flag indicates potential ticket managers
    LIMIT 1;

    -- Check if the determined manager is absent
    IF category_manager_id IS NOT NULL THEN
        approver_absent := EXISTS(
            SELECT 1
            FROM Fproject.user_status
            WHERE user_id = category_manager_id
            AND now() BETWEEN start_date AND end_date
        );

        -- If the manager is present and not absent, assign the ticket to them
        IF NOT approver_absent THEN
            NEW.assigned_to := category_manager_id;
            RETURN NEW;
        END IF;
    END IF;

    -- If no category-based manager is found or they are absent, check for absence of initially assigned approver
    approver_absent := EXISTS(
        SELECT 1
        FROM Fproject.user_status
        WHERE user_id = NEW.assigned_to
        AND now() BETWEEN start_date AND end_date
    );

    -- Reassignment logic if initially assigned approver is absent
    IF approver_absent THEN
        IF NEW.fallback_approver IS NOT NULL AND NOT EXISTS(
            SELECT 1
            FROM Fproject.user_status
            WHERE user_id = NEW.fallback_approver
            AND now() BETWEEN start_date AND end_date
        ) THEN
            NEW.assigned_to := NEW.fallback_approver;
        ELSE
            -- Select a fallback approver who is available
            SELECT u.id INTO fallback_user_id
            FROM Fproject."user" u
            WHERE u.is_fallback_approver = TRUE
            AND u.id NOT IN (
                SELECT us.user_id FROM Fproject.user_status us WHERE now() BETWEEN us.start_date AND us.end_date
            )
            LIMIT 1;

            IF FOUND THEN
                NEW.assigned_to := fallback_user_id;
            ELSE
                -- Assign to an administrator if no suitable fallback is found
                SELECT u.id INTO admin_user_id
                FROM Fproject."user" u
                JOIN Fproject.role r ON u.role_id = r.id
                WHERE r.role_name = 'Administrator'
                LIMIT 1;

                IF FOUND THEN
                    NEW.assigned_to := admin_user_id;
                ELSE
                    RAISE EXCEPTION 'No available fallback or administrator found for ticket reassignment.';
                END IF;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER trigger_redirect_new_ticket
BEFORE INSERT ON Fproject.ticket
FOR EACH ROW
EXECUTE FUNCTION check_and_redirect_ticket();

CREATE TRIGGER trigger_redirect_updated_ticket
BEFORE UPDATE OF assigned_to ON Fproject.ticket
FOR EACH ROW
WHEN (OLD.assigned_to IS DISTINCT FROM NEW.assigned_to)
EXECUTE FUNCTION check_and_redirect_ticket();


-- Function to update the user's role after completing the onboarding checklist
CREATE OR REPLACE FUNCTION update_user_role_after_onboarding()
RETURNS TRIGGER AS $$
DECLARE
    all_items_completed BOOLEAN;
    new_employee_role_id INT := 4;
    user_role_id INT := 3;
BEGIN
    -- Check if all checklist items for the user are completed
    SELECT NOT EXISTS (
        SELECT 1
        FROM Fproject.user_checklist_status ucs
        JOIN Fproject.checklist_item ci ON ucs.checklist_item_id = ci.id
        WHERE ucs.user_id = NEW.user_id
        AND ucs.is_completed = FALSE
    ) INTO all_items_completed;

    -- If all items are completed, update the user's role to 'User'
    IF all_items_completed THEN
        UPDATE Fproject."user"
        SET role_id = user_role_id
        WHERE id = NEW.user_id AND role_id = new_employee_role_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_onboarding_completion
AFTER UPDATE ON Fproject.user_checklist_status
FOR EACH ROW
EXECUTE FUNCTION update_user_role_after_onboarding();

-- Create a trigger function that will be called when a new user is added
CREATE OR REPLACE FUNCTION Fproject.populate_user_checklist_status()
    RETURNS TRIGGER AS $$
DECLARE
    userRoleName VARCHAR;
BEGIN
    -- Determine the role name of the new user
    SELECT role_name INTO userRoleName
    FROM Fproject.role
    WHERE id = NEW.role_id;

    IF userRoleName != 'New Employee' THEN
        -- If the user's role is not 'New Employee', mark all checklist items as completed
        INSERT INTO Fproject.user_checklist_status (user_id, checklist_item_id, is_completed, completed_at)
        SELECT NEW.id, checklist_item.id, TRUE, CURRENT_TIMESTAMP   -- becasue the user is not a new employee
        FROM Fproject.checklist_item;
    ELSE
        -- If the user's role is 'New Employee', mark all checklist items as not completed
        INSERT INTO Fproject.user_checklist_status (user_id, checklist_item_id, is_completed, completed_at)
        SELECT NEW.id, checklist_item.id, FALSE, NULL
        FROM Fproject.checklist_item;
    END IF;

    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;
-- Create a trigger that will call the trigger function when a new user is added
CREATE TRIGGER trigger_populate_user_checklist_status
    AFTER INSERT ON Fproject."user"
    FOR EACH ROW EXECUTE FUNCTION Fproject.populate_user_checklist_status();

-- Create a trigger function that will be called when a new checklist item is added
CREATE OR REPLACE FUNCTION Fproject.update_checklist_template_item()
    RETURNS TRIGGER AS $$
BEGIN
    -- Check if we are inserting a new checklist item
    IF TG_OP = 'INSERT' THEN
        -- Insert a new checklist_template_item for each existing checklist_template
        -- only if the combination doesn't already exist
        INSERT INTO Fproject.checklist_template_item (checklist_template_id, checklist_item_id)
        SELECT id, NEW.id
        FROM Fproject.checklist_template
        WHERE NOT EXISTS (
            SELECT 1
            FROM Fproject.checklist_template_item
            WHERE checklist_template_id = Fproject.checklist_template.id
              AND checklist_item_id = NEW.id
        );
    ELSIF TG_OP = 'DELETE' THEN
        -- Remove all associations with the deleted checklist_item from checklist_template_item
        DELETE FROM Fproject.checklist_template_item WHERE checklist_item_id = OLD.id;
    END IF;

    -- Return the affected row
    RETURN NULL; -- Result is ignored since this is an AFTER trigger
END;
$$

    LANGUAGE plpgsql;



-- Trigger function for handling insertions into checklist_item
CREATE OR REPLACE FUNCTION Fproject.on_checklist_item_insert()
    RETURNS TRIGGER AS $$
BEGIN
    -- For each checklist_template, insert a new association with the new checklist_item
    INSERT INTO Fproject.checklist_template_item (checklist_template_id, checklist_item_id)
    SELECT checklist_template.id, NEW.id
    FROM Fproject.checklist_template;

    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

-- Trigger for insertions
CREATE TRIGGER trigger_checklist_item_insert
    AFTER INSERT ON Fproject.checklist_item
    FOR EACH ROW
EXECUTE FUNCTION Fproject.on_checklist_item_insert();

-- Trigger function for handling deletions from checklist_item
CREATE OR REPLACE FUNCTION Fproject.on_checklist_item_delete()
    RETURNS TRIGGER AS $$
BEGIN
    -- Delete associations with the removed checklist_item from checklist_template_item
    DELETE FROM Fproject.checklist_template_item WHERE checklist_item_id = OLD.id;

    RETURN OLD;
END;
$$
    LANGUAGE plpgsql;

-- Trigger for deletions
CREATE TRIGGER trigger_checklist_item_delete
    AFTER DELETE ON Fproject.checklist_item
    FOR EACH ROW
EXECUTE FUNCTION Fproject.on_checklist_item_delete();

-- Trigger function adds a new comment in ticket
CREATE OR REPLACE FUNCTION Fproject.add_ticket_comment(
    p_ticket_id INT,
    p_user_id INT,
    p_comment TEXT,
    p_attachment BYTEA,
    p_attachment_name VARCHAR,
    p_attachment_type VARCHAR
)
    RETURNS VOID AS $$
BEGIN
    INSERT INTO Fproject.ticket_comment (ticket_id, user_id, comment, attachment, attachment_name, attachment_type )
    VALUES (p_ticket_id, p_user_id, p_comment, p_attachment, p_attachment_name, p_attachment_type);
END;
$$
    LANGUAGE plpgsql;

-- Function to update user_categories and set completed_at after ticket closure
CREATE OR REPLACE FUNCTION Fproject.update_user_categories_on_ticket_closure()
    RETURNS TRIGGER AS $$
DECLARE
    verifying_status_id INT;
BEGIN
    -- Fetch the 'Closed' status ID dynamically
    SELECT id INTO verifying_status_id FROM Fproject.ticket_status WHERE status_name = 'Verifying';

    -- Check if the ticket status is being changed to 'Verifying'
    IF NEW.status_id = verifying_status_id THEN
        -- Check if the record already exists
        IF NOT EXISTS (
            SELECT 1 FROM Fproject.user_categories
            WHERE user_id = NEW.user_id
              AND category_id = NEW.category_id
              AND permission_id = NEW.permission_required
              AND position_id = NEW.requested_position
        ) THEN
            -- Update or insert the user_categories record
            INSERT INTO Fproject.user_categories (user_id, category_id, permission_id, position_id)
            VALUES (NEW.user_id, NEW.category_id, NEW.permission_required, NEW.requested_position)
            ON CONFLICT (user_id, category_id, permission_id, position_id) DO UPDATE
                SET permission_id = NEW.permission_required, position_id = NEW.requested_position;
        END IF;
    END IF;

    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

-- Trigger to call the function after updating a ticket
CREATE TRIGGER trigger_update_user_categories_on_ticket_closure
    AFTER UPDATE ON Fproject.ticket
    FOR EACH ROW
    WHEN (OLD.status_id IS DISTINCT FROM NEW.status_id)
EXECUTE FUNCTION Fproject.update_user_categories_on_ticket_closure();

CREATE OR REPLACE FUNCTION Fproject.update_completed_at()
    RETURNS TRIGGER AS $$
DECLARE
    closed_status_id INT;
BEGIN
    -- Fetch the 'Closed' status ID dynamically
    SELECT id INTO closed_status_id FROM Fproject.ticket_status WHERE status_name = 'Closed';

    -- Check if the status_id has been updated to the 'Closed' status
    IF NEW.status_id = closed_status_id THEN
        NEW.completed_at := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER update_completed_at_trigger
    BEFORE UPDATE ON Fproject.ticket
    FOR EACH ROW
    WHEN (OLD.status_id IS DISTINCT FROM NEW.status_id)
EXECUTE FUNCTION Fproject.update_completed_at();
---------------------------------------------------------------------------------
    -- Inserting sample data

INSERT INTO Fproject.employment_status (employment_name) VALUES
('Employee'),
('Contractor'),
('Student/Intern'),
('Other');

INSERT INTO Fproject.role (role_name, role_description) VALUES
('Administrator', 'Full access to all features'),
('Manager', 'Can manage tickets and users that are assigned to his projects'),
('User', 'Can create and comment on own tickets'),
('New Employee', 'Limited access for new employees till they complete the onboarding process');


INSERT INTO Fproject.department (dep_name) VALUES
('IT'),
('HR'),
('Finance');

INSERT INTO Fproject.position (pos_name) VALUES
('Software Engineer'),
('Project Manager'),
('Business Analyst'),
('QA Engineer'),
('DevOps Engineer'),
('Data Analyst'),
('UI/UX Designer'),
('Technical Writer'),
('Scrum Master'),
('Designer'),
('System Administrator'),
('Network Administrator'),
('Database Administrator'),
('Security Analyst'),
('Help Desk Technician'),
('IT Support Specialist'),
('IT Manager'),
('HR Manager'),
('Finance Manager');

INSERT INTO Fproject.certificates (certificate_name, is_permanent, certificate_valid_from, certificate_valid_till) VALUES
('AWS Certified Solutions Architect', TRUE, '2020-01-01', '2025-01-01'),
('Microsoft Certified: Azure Administrator Associate', TRUE, '2020-01-01', '2025-01-01'),
('Certified ScrumMaster', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Systems Security Professional (CISSP)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Systems Auditor (CISA)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Security Manager (CISM)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Ethical Hacker (CEH)', TRUE, '2020-01-01', '2025-01-01'),
('CompTIA Security+', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Systems Security Professional (CISSP)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Systems Auditor (CISA)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Information Security Manager (CISM)', TRUE, '2020-01-01', '2025-01-01'),
('Certified Ethical Hacker (CEH)', TRUE, '2020-01-01', '2025-01-01'),
('CompTIA Security+', TRUE, '2020-01-01', '2025-01-01');

INSERT INTO Fproject.ticket_status (status_name, color, days_to_update) VALUES
('Open', 16711680, NULL), -- Red
('In Progress', 16776960, NULL), -- Yellow
('Verifying', 16776960, 14), -- Yellow
('Rejected', 255, NULL), -- White
('Closed', 65280, NULL); -- Green

INSERT INTO Fproject.ticket_priorities (priority_name, color) VALUES
('Low', 65280), -- Green
('Medium', 16776960), -- Yellow
('High', 167506), -- Orange
('Urgent', 16711680); -- Red

INSERT INTO Fproject.categories (category_name) VALUES
('Gondor'),
('Mordor'),
('Rivendell'),
('Isengard'),
('Shire'),
('Rohan'),
('Lothlorien');

INSERT INTO Fproject.permissions (permission_name) VALUES
('Read'),
('Write'),
('None');

INSERT INTO Fproject."user" (WBI, f_name, l_name, email, role_id, employment_status_id, password_hash, is_fallback_approver) VALUES
('WBI123', 'John', 'Doe', 'test@test.com', 1, 1, 'password', FALSE),
('WBI456', 'Jane', 'Doe', 'test2@test.com', 2, 1, 'password', FALSE),
('WBI789', 'Alice', 'Smith', 'test3@test.com', 3, 1, 'password', TRUE),
('WBI101', 'Bob', 'Johnson', 'test4@test.com', 3, 1, 'password', FALSE),
('WBI107', 'Bob', 'Johnson', 'test6@test.com', 4, 1, 'password', FALSE);



INSERT INTO Fproject.checklist_template (checklist_name, role_id) VALUES
('Onboarding Checklist', 4); -- New Employee

INSERT INTO Fproject.checklist_item (item_description) VALUES
('Complete HR Training'),
('Setup Workstation'),
('Review Safety Protocol'),
('Install any necessary software and tools required for your role, such as IDEs, version control systems, and communication tools'),
('Connect the computer to the network and log in using the provided credentials'),
('The IT department will provide you with a company laptop or desktop computer'),
('Customize your workspace settings, such as display resolution, keyboard and mouse preferences, and browser settings'),
('Familiarize yourself with the offices fire safety plan, including evacuation routes and assembly points'),
('Know the location of fire extinguishers and how to use them in case of an emergency'),
('Participate in regular fire drills to practice evacuation procedures'),
('Do not overload electrical outlets or use damaged electrical cords'),
('Keep liquids away from electrical equipment to avoid spills and potential electrical hazards'),
('Report any electrical issues or malfunctions to the facilities team immediately'),
('Adjust your chair, desk, and computer monitor to maintain proper posture and reduce strain on your neck, back, and wrists'),
('Take regular breaks to stretch and rest your eyes, especially when working for extended periods'),
('Attend the companys HR orientation session to learn about policies, benefits, and company culture'),
('Review and acknowledge the employee handbook, which outlines the companys rules, regulations, and expectations'),
('Complete any required training modules, such as diversity and inclusion, sexual harassment prevention, or data privacy and security');


INSERT INTO Fproject.user_checklist_status (user_id, checklist_item_id, is_completed, completed_at) VALUES
(5, 1, TRUE, CURRENT_TIMESTAMP),
(5, 2, TRUE, CURRENT_TIMESTAMP),
(5, 3, FALSE, NULL);

INSERT INTO Fproject.user_categories (user_id, category_id, permission_id, position_id) VALUES
(1, 1, 1, 1), -- John Doe has read permission for Gendalf
(2, 1, 2, 2), -- Jane Doe has write permission for Gendalf
(3, 1, 1, 3), -- Alice Smith has read permission for Gendalf
(4, 2, 1, 3), -- Bob Johnson has read permission for CoolChip
(5, 3, 2, 3); -- Bob Johnson has write permission for Banana



INSERT INTO Fproject.ticket (subject, content, status_id, priority_id, user_id, created_at, updated_at, completed_at, assigned_to, fallback_approver, category_id, attachment, permission_required, requested_position) VALUES
('Issue with server', 'The server is down and needs immediate attention', 1, 4, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 2, NULL, 1, NULL, 2, 8),
('Need access to new software', 'I require access to the new software for testing purposes', 1, 2, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 2, 3, 2, NULL, 1, 6),
('Request for new laptop', 'My laptop is outdated and needs to be replaced', 1, 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, 1, NULL, 3, NULL, 1, 5);



INSERT INTO Fproject.ticket_comment (ticket_id, user_id, comment, status_change, priority_change, created_at) VALUES
(1, 1, 'This is a commenfafhht', 1, 1, CURRENT_TIMESTAMP),
(1, 2, 'This is anotadfhdhher comment', 1, 1, CURRENT_TIMESTAMP),
(2, 2, 'This is a commafhadfhadaeeeeent', 1, 1, CURRENT_TIMESTAMP),
(3, 1, 'This is a commafhadfhent', 1, 1, CURRENT_TIMESTAMP);

INSERT INTO Fproject.notifications (user_id, ticket_id, notification_type, message, created_at) VALUES
(2, 1, 'New Ticket', 'A new ticket has been assigned to you.', CURRENT_TIMESTAMP),
(2, 2, 'New Ticket', 'A new ticket has been assigned to you.', CURRENT_TIMESTAMP),
(2, 3, 'New Ticket', 'A new ticket has been assigned to you.', CURRENT_TIMESTAMP);




INSERT INTO Fproject.user_status (user_id, status, start_date, end_date) VALUES
(4, 'Out of Office', '2021-01-01', '2021-01-10'),
(2, 'Busy', '2021-01-01', '2021-01-10');

INSERT INTO Fproject.user_status_audit (user_id, old_status, new_status, changed_by_user_id) VALUES
(4, 'Available', 'Out of Office', 3),
(2, 'Available', 'Busy', 3);

INSERT INTO Fproject.department_user (department_id, user_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(2, 5),
(3, 5);

INSERT INTO Fproject.position_user (position_id, user_id) VALUES
(1, 5),
(2, 2),
(3, 3),
(4, 4),
(5, 1),
(6, 5),
(7, 5),
(8, 5),
(9, 5),
(10, 5),
(11, 5),
(12, 5),
(13, 5),
(14, 5),
(15, 5),
(16, 5),
(17, 5),
(18, 5);

INSERT INTO Fproject.certificates_user (certificate_id, user_id) VALUES
(1, 1),
(2, 2),
(3, 3);


---------------------------------------------------------------------------------
    -- Views

-- View to get the list of managers and the categories they are assigned to
CREATE OR REPLACE VIEW Fproject.manager_category_assignments AS
SELECT
    uc.user_id AS manager_id,
    uc.category_id,
    u.f_name || ' ' || u.l_name AS manager_name,
    c.category_name
FROM
    Fproject.user_categories uc
JOIN
    Fproject."user" u ON uc.user_id = u.id
JOIN
    Fproject.categories c ON uc.category_id = c.category_id
JOIN
    Fproject.role r ON u.role_id = r.id
WHERE
    r.role_name = 'Manager';


-- View the fallback approvers and managers who are available
CREATE OR REPLACE VIEW Fproject.available_fallback_approvers AS
    SELECT u.id, u.f_name, u.l_name
    FROM Fproject."user" u
    WHERE u.is_fallback_approver = TRUE
    AND u.id NOT IN (
        SELECT us.user_id
        FROM Fproject.user_status us
        WHERE now() BETWEEN us.start_date AND us.end_date
    );

-- View shows the number of tickets in each status, giving you a quick overview of how many tickets are open, closed, in progress, etc.
CREATE OR REPLACE VIEW Fproject.ticket_volumes_by_status AS
SELECT
    ts.status_name,
    COUNT(t.id) AS total_tickets
FROM
    Fproject.ticket_status ts
LEFT JOIN
    Fproject.ticket t ON ts.id = t.status_id
GROUP BY
    ts.status_name;

--  View calculates the average time taken to close tickets, providing insight into resolution efficiency.
CREATE OR REPLACE VIEW Fproject.average_resolution_time AS
SELECT
    AVG(EXTRACT(EPOCH FROM (t.completed_at - t.created_at)) / 3600) AS average_hours_to_close
FROM
    Fproject.ticket t
WHERE
    t.status_id = (SELECT id FROM Fproject.ticket_status WHERE status_name = 'Closed')
    AND t.completed_at IS NOT NULL;

-- View to get the total number of tickets in each category
CREATE OR REPLACE VIEW Fproject.tickets_per_category AS
SELECT
    c.category_name,
    COUNT(t.id) AS total_tickets
FROM
    Fproject.categories c
LEFT JOIN
    Fproject.ticket t ON c.category_id = t.category_id
GROUP BY
    c.category_name;

-- View shows the activity of users based on ticket creation, giving insights into which users are raising the most tickets.
CREATE OR REPLACE VIEW Fproject.user_activity_report AS
SELECT
    u.id AS user_id,
    u.f_name || ' ' || u.l_name AS user_name,
    COUNT(t.id) AS total_tickets_created
FROM
    Fproject."user" u
JOIN
    Fproject.ticket t ON u.id = t.user_id
GROUP BY
    u.id;

-- To list all the categories available
SELECT
    category_id,
    category_name
FROM
    Fproject.categories;

-- To list all the permissions available
SELECT
    id,
    permission_name
FROM
    Fproject.permissions;


CREATE VIEW ticketsByRole AS
SELECT
    t.id,
    t.subject,
    t.content,
    ts.status_name AS ticket_status,
    tp.priority_name AS ticket_priority,
    u.f_name AS user_first_name,
    u.l_name AS user_last_name,
    u.email AS user_email,
    r.role_name AS user_role,
    es.employment_name AS user_employment_status,
    c.category_name AS ticket_category,
    t.created_at,
    t.updated_at,
    t.completed_at,
    assigned.f_name AS assigned_to_first_name,
    assigned.l_name AS assigned_to_last_name,
    fallback.f_name AS fallback_approver_first_name,
    fallback.l_name AS fallback_approver_last_name
FROM
    Fproject.ticket t
        JOIN Fproject.ticket_status ts ON t.status_id = ts.id
        JOIN Fproject.ticket_priorities tp ON t.priority_id = tp.id
        JOIN Fproject."user" u ON t.user_id = u.id
        JOIN Fproject.role r ON u.role_id = r.id
        JOIN Fproject.employment_status es ON u.employment_status_id = es.id
        JOIN Fproject.categories c ON t.category_id = c.category_id
        LEFT JOIN Fproject."user" assigned ON t.assigned_to = assigned.id
        LEFT JOIN Fproject."user" fallback ON t.fallback_approver = fallback.id
WHERE
    (r.role_name = 'Administrator') OR
    (r.role_name = 'Manager' AND EXISTS (
        SELECT 1
        FROM Fproject.user_categories uc
        WHERE uc.user_id = u.id AND uc.category_id = t.category_id
    )) OR
    (t.user_id = u.id);


---------------------------------------------------------------------------------
    -- Stored Procedures

-- Stored procedure to create a new user
CREATE OR REPLACE PROCEDURE Fproject.CreateNewUser(
    p_WBI VARCHAR,
    p_f_name VARCHAR,
    p_l_name VARCHAR,
    p_email VARCHAR,
    p_password_hash VARCHAR,
    p_role_name VARCHAR DEFAULT 'Newcommer', -- Default role
    p_employment_name VARCHAR DEFAULT 'Employee' -- Default employment status
)
LANGUAGE plpgsql AS $$
DECLARE
    v_role_id INT;
    v_employment_status_id INT;
    v_user_exists INT;
BEGIN
    -- Check if the email is already in use
    SELECT COUNT(*) INTO v_user_exists FROM Fproject."user" WHERE email = p_email;
    IF v_user_exists > 0 THEN
        RAISE EXCEPTION 'The email % is already in use.', p_email;
    END IF;

    -- Get the role_id for the provided role name
    SELECT id INTO v_role_id FROM Fproject.role WHERE role_name = p_role_name;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Role % not found.', p_role_name;
    END IF;

    -- Get the employment_status_id for the provided employment name
    SELECT id INTO v_employment_status_id FROM Fproject.employment_status WHERE employment_name = p_employment_name;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employment status % not found.', p_employment_name;
    END IF;

    -- Insert the new user
    INSERT INTO Fproject."user" (WBI, f_name, l_name, email, role_id, employment_status_id, password_hash)
    VALUES (p_WBI, p_f_name, p_l_name, p_email, v_role_id, v_employment_status_id, p_password_hash);
END;
$$;

-- Stored procedure to update user details
CREATE OR REPLACE PROCEDURE Fproject.UpdateUser(
    p_user_id INT,
    p_f_name VARCHAR default NULL,
    p_l_name VARCHAR default NULL,
    p_email VARCHAR default NULL,
    p_role_name VARCHAR default NULL,
    p_employment_name VARCHAR default NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_role_id INT;
    v_employment_status_id INT;
BEGIN
    -- Update role_id if p_role_name is provided
    IF p_role_name IS NOT NULL THEN
        SELECT id INTO v_role_id FROM Fproject.role WHERE role_name = p_role_name;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Role % not found.', p_role_name;
        END IF;
        UPDATE Fproject."user" SET role_id = v_role_id WHERE id = p_user_id;
    END IF;

    -- Update employment_status_id if p_employment_name is provided
    IF p_employment_name IS NOT NULL THEN
        SELECT id INTO v_employment_status_id FROM Fproject.employment_status WHERE employment_name = p_employment_name;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Employment status % not found.', p_employment_name;
        END IF;
        UPDATE Fproject."user" SET employment_status_id = v_employment_status_id WHERE id = p_user_id;
    END IF;

    -- Update other fields if provided
    IF p_f_name IS NOT NULL THEN
        UPDATE Fproject."user" SET f_name = p_f_name WHERE id = p_user_id;
    END IF;

    IF p_l_name IS NOT NULL THEN
        UPDATE Fproject."user" SET l_name = p_l_name WHERE id = p_user_id;
    END IF;

    IF p_email IS NOT NULL THEN
        -- Optionally, check for email uniqueness before updating
        UPDATE Fproject."user" SET email = p_email WHERE id = p_user_id;
    END IF;
END;
$$;

-- Stored procedure to delete a user
CREATE OR REPLACE PROCEDURE Fproject.DeleteUser(p_user_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Fproject."user" WHERE id = p_user_id;
END;
$$;


CREATE OR REPLACE PROCEDURE Fproject.EditCategoryAccess(
    p_user_id INT,
    p_category_id INT,
    p_permission_name VARCHAR,
    p_position_id INT DEFAULT NULL
)
    LANGUAGE plpgsql AS $$
DECLARE
    v_permission_id INT;
    v_role_id INT;
BEGIN
    -- Retrieve the permission ID for the given permission name
    SELECT id INTO v_permission_id FROM Fproject.permissions WHERE permission_name = p_permission_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Permission % not found.', p_permission_name;
    END IF;

    -- Retrieve the role ID for the user
    SELECT role_id INTO v_role_id FROM Fproject."user" WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User with ID % not found.', p_user_id;
    END IF;

    -- Check if the user already has access to the category
    IF EXISTS(SELECT 1 FROM Fproject.user_categories WHERE user_id = p_user_id AND category_id = p_category_id) THEN
        -- Update existing permission and position
        UPDATE Fproject.user_categories
        SET permission_id = v_permission_id,
            position_id = COALESCE(p_position_id, position_id)
        WHERE user_id = p_user_id AND category_id = p_category_id;
    ELSE
        -- Grant new access
        INSERT INTO Fproject.user_categories (user_id, category_id, permission_id, position_id)
        VALUES (p_user_id, p_category_id, v_permission_id, p_position_id);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE Fproject.CreateTicket(
    p_subject VARCHAR,
    p_content TEXT,
    p_status_name VARCHAR,
    p_priority_name VARCHAR,
    p_user_id INT,
    p_manager_wbi VARCHAR,
    p_category_name VARCHAR,
    p_attachment BYTEA,
    p_permission_required_name VARCHAR,
    p_requested_position_name VARCHAR,
    p_attachment_name VARCHAR,
    p_attachment_type VARCHAR
)
    LANGUAGE plpgsql AS $$
DECLARE
    v_status_id INT;
    v_priority_id INT;
    v_category_id INT;
    v_requested_position_id INT;
    v_manager_id INT;
    v_permission_required_id INT;
BEGIN
    -- Convert names to IDs
    SELECT id INTO v_status_id FROM Fproject.ticket_status WHERE status_name = p_status_name;
    SELECT id INTO v_priority_id FROM Fproject.ticket_priorities WHERE priority_name = p_priority_name;
    SELECT category_id INTO v_category_id FROM Fproject.categories WHERE category_name = p_category_name;
    SELECT id INTO v_requested_position_id FROM Fproject.position WHERE pos_name = p_requested_position_name;
    SELECT id INTO v_manager_id FROM Fproject."user" WHERE WBI = p_manager_wbi;
    SELECT id INTO v_permission_required_id FROM Fproject.permissions WHERE permission_name = p_permission_required_name;

    -- Insert the ticket
    INSERT INTO Fproject.ticket(
        subject, content, status_id, priority_id, user_id, created_at, category_id, requested_position, attachment, assigned_to, permission_required, attachment_name, attachment_type
    )
    VALUES (
               p_subject, p_content, v_status_id, v_priority_id, p_user_id, CURRENT_TIMESTAMP, v_category_id, v_requested_position_id, p_attachment, v_manager_id, v_permission_required_id, p_attachment_name, p_attachment_type
           );
END;
$$
;





-- Stored procedure to update a ticket
CREATE OR REPLACE PROCEDURE Fproject.UpdateTicket(
    p_ticket_id INT,
    p_user_id INT,
    p_new_status VARCHAR DEFAULT NULL,
    p_new_priority VARCHAR DEFAULT NULL,
    p_new_assigned_to_name VARCHAR DEFAULT NULL,
    p_new_fallback_approver_name VARCHAR DEFAULT NULL,
    p_new_category_name VARCHAR DEFAULT NULL,
    p_comment TEXT DEFAULT NULL,
    p_file_data BYTEA DEFAULT NULL,
    p_is_manager_or_admin BOOLEAN DEFAULT FALSE,
    p_new_position_name VARCHAR DEFAULT NULL,
    p_new_permission_name VARCHAR DEFAULT NULL
)
    LANGUAGE plpgsql AS $$
DECLARE
    v_status_id INT;
    v_priority_id INT;
    v_position_id INT;
    v_permission_id INT;
    v_assigned_to_id INT;
    v_fallback_approver_id INT;
    v_category_id INT;
    v_event_payload JSONB;
    v_changes JSONB;
    v_created_at TIMESTAMP;
    v_updated_at TIMESTAMP;
    v_time_diff INTERVAL;
    v_comment_id INT;
    v_comment_event_payload JSONB;
BEGIN
    v_changes := '{}'::JSONB;

    -- Get the created_at and updated_at timestamps for the ticket
    SELECT created_at, updated_at INTO v_created_at, v_updated_at
    FROM Fproject.ticket
    WHERE id = p_ticket_id;

    -- Calculate the time difference between created_at and updated_at
    v_time_diff := v_updated_at - v_created_at;

    -- Restrict updates of certain fields to managers or admins
    IF p_is_manager_or_admin THEN
        IF p_new_status IS NOT NULL THEN
            SELECT id INTO v_status_id FROM Fproject.ticket_status WHERE status_name = p_new_status;
            IF FOUND AND v_status_id <> (SELECT status_id FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET status_id = v_status_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{status}', to_jsonb(p_new_status));
                v_event_payload := jsonb_build_object('action', 'status_change', 'new_status', p_new_status);

            END IF;
        END IF;

        IF p_new_priority IS NOT NULL THEN
            SELECT id INTO v_priority_id FROM Fproject.ticket_priorities WHERE priority_name = p_new_priority;
            IF FOUND AND v_priority_id <> (SELECT priority_id FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET priority_id = v_priority_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{priority}', to_jsonb(p_new_priority));
                v_event_payload := jsonb_build_object('action', 'priority_change', 'new_priority', p_new_priority);

            END IF;
        END IF;

        IF p_new_assigned_to_name IS NOT NULL THEN
            SELECT id INTO v_assigned_to_id FROM Fproject."user" WHERE CONCAT(f_name, ' ', l_name) = p_new_assigned_to_name;
            IF FOUND AND v_assigned_to_id <> (SELECT assigned_to FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET assigned_to = v_assigned_to_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{assigned_to}', to_jsonb(p_new_assigned_to_name));
                v_event_payload := jsonb_build_object('action', 'assign_change', 'new_assigned_to', p_new_assigned_to_name);

            END IF;
        END IF;

        IF p_new_fallback_approver_name IS NOT NULL THEN
            SELECT id INTO v_fallback_approver_id FROM Fproject."user" WHERE CONCAT(f_name, ' ', l_name) = p_new_fallback_approver_name;
            IF FOUND AND v_fallback_approver_id <> (SELECT fallback_approver FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET fallback_approver = v_fallback_approver_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{fallback_approver}', to_jsonb(p_new_fallback_approver_name));
                v_event_payload := jsonb_build_object('action', 'fallback_approver_change', 'new_fallback_approver', p_new_fallback_approver_name);

            END IF;
        END IF;

        IF p_new_category_name IS NOT NULL THEN
            SELECT category_id INTO v_category_id FROM Fproject.categories WHERE category_name = p_new_category_name;
            IF FOUND AND v_category_id <> (SELECT category_id FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET category_id = v_category_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{category}', to_jsonb(p_new_category_name));
                v_event_payload := jsonb_build_object('action', 'category_change', 'new_category', p_new_category_name);

            END IF;
        END IF;

        IF p_new_position_name IS NOT NULL THEN
            SELECT id INTO v_position_id FROM Fproject.position WHERE pos_name = p_new_position_name;
            IF FOUND AND v_position_id <> (SELECT requested_position FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET requested_position = v_position_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{position}', to_jsonb(p_new_position_name));
                v_event_payload := jsonb_build_object('action', 'position_change', 'new_position', p_new_position_name);

            END IF;
        END IF;

        IF p_new_permission_name IS NOT NULL THEN
            SELECT id INTO v_permission_id FROM Fproject.permissions WHERE permission_name = p_new_permission_name;
            IF FOUND AND v_permission_id <> (SELECT permission_required FROM Fproject.ticket WHERE id = p_ticket_id) THEN
                UPDATE Fproject.ticket SET permission_required = v_permission_id WHERE id = p_ticket_id;
                v_changes := jsonb_set(v_changes, '{permission}', to_jsonb(p_new_permission_name));
                v_event_payload := jsonb_build_object('action', 'permission_change', 'new_permission', p_new_permission_name);

            END IF;
        END IF;
    END IF;

    -- Store the consolidated changes in the event store if there are any changes
    IF v_changes <> '{}'::JSONB THEN
        v_event_payload := jsonb_build_object('action', 'ticket_updated', 'changes', v_changes);
        INSERT INTO Fproject.event_store(event_type, aggregate_type, aggregate_id, payload, user_id, wbi)
        VALUES ('ticket_updated', 'ticket', p_ticket_id, v_event_payload, p_user_id, (SELECT WBI FROM Fproject."user" WHERE id = p_user_id));
    END IF;

    -- Add a comment and file if provided
    IF p_comment IS NOT NULL OR p_file_data IS NOT NULL THEN
        INSERT INTO Fproject.ticket_comment (ticket_id, user_id, comment, file_data, created_at)
        VALUES (p_ticket_id, p_user_id, p_comment, p_file_data, CURRENT_TIMESTAMP)
        RETURNING id INTO v_comment_id;

        -- Log comment/file addition event
        IF v_time_diff <= INTERVAL '5 minutes' THEN
            -- If the update is within 5 minutes of ticket creation/update, log it as part of the comment event
            v_comment_event_payload := json_build_object('action', 'comment_file_added', 'comment', p_comment, 'comment_id', v_comment_id);
        ELSE
            -- Otherwise, log it as a separate event
            v_comment_event_payload := json_build_object('action', 'comment_file_added', 'comment', p_comment, 'comment_id', v_comment_id);
            INSERT INTO Fproject.event_store(event_type, aggregate_type, aggregate_id, payload, user_id, wbi)
            VALUES ('comment_file_added', 'ticket', p_ticket_id, v_comment_event_payload, p_user_id, (SELECT WBI FROM Fproject."user" WHERE id = p_user_id));
        END IF;
    END IF;

    -- Check if the user exists
    IF p_user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Fproject."user" WHERE id = p_user_id) THEN
        RAISE EXCEPTION 'User with ID % does not exist.', p_user_id;
    END IF;

    -- Update the updated_at timestamp
    UPDATE Fproject.ticket SET updated_at = CURRENT_TIMESTAMP WHERE id = p_ticket_id;
END;
$$
;


CREATE OR REPLACE PROCEDURE Fproject.CloseOrDeleteTicket(p_ticket_id INT, p_user_id INT)
    LANGUAGE plpgsql AS $$
DECLARE
    v_closed_status_id INT;
    v_created_at TIMESTAMP;
    v_ticket_exists BOOLEAN;
    v_user_wbi TEXT;
BEGIN
    -- Check if the ticket exists
    SELECT EXISTS(SELECT 1 FROM Fproject.ticket WHERE id = p_ticket_id) INTO v_ticket_exists;

    IF NOT v_ticket_exists THEN
        RAISE EXCEPTION 'Ticket with ID % does not exist.', p_ticket_id;
    END IF;

    -- Check if the user has permission to close or delete the ticket
    IF NOT EXISTS (
        SELECT 1 FROM Fproject.ticket t
                          JOIN Fproject."user" u ON t.user_id = u.id
                          JOIN Fproject.role r ON u.role_id = r.id
        WHERE t.id = p_ticket_id AND (r.role_name = 'Administrator' OR r.role_name = 'Manager')
    ) THEN
        RAISE EXCEPTION 'User does not have permission to close or delete this ticket.';
    END IF;

    -- Retrieve the 'Closed' status_id
    SELECT id INTO v_closed_status_id FROM Fproject.ticket_status WHERE status_name = 'Closed';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Status "Closed" not found.';
    END IF;

    -- Get the created_at timestamp of the ticket and the WBI of the user
    SELECT created_at, (SELECT WBI FROM Fproject."user" WHERE id = p_user_id) INTO v_created_at, v_user_wbi FROM Fproject.ticket WHERE id = p_ticket_id;

    -- Log the intent to delete or close the ticket before performing the action
-- Log the actual deletion or closure event
    INSERT INTO Fproject.event_store(event_type, aggregate_type, aggregate_id, payload, user_id, wbi)
    VALUES (
               CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'ticket_deletion_attempt' ELSE 'ticket_closure_attempt' END,
               'ticket',
               p_ticket_id,
               -- Use jsonb_build_object to ensure the payload is of type JSON
               jsonb_build_object(
                       'action',
                       CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'attempted_ticket_deletion' ELSE 'attempted_ticket_closure' END,
                       'details',
                       jsonb_build_object('action', CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'attempted_ticket_deletion' ELSE 'attempted_ticket_closure' END)
               ),
               p_user_id,
               v_user_wbi
           );

    -- Determine if the ticket was created within the last 2 minutes
    IF (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN
        -- Delete related notifications first
        DELETE FROM Fproject.notifications WHERE ticket_id = p_ticket_id;

        -- Delete the ticket if within 2 minutes of creation
        DELETE FROM Fproject.ticket WHERE id = p_ticket_id;
    ELSE
        -- Update the ticket status to 'Closed' if it's past 2 minutes
        UPDATE Fproject.ticket
        SET status_id = v_closed_status_id, completed_at = CURRENT_TIMESTAMP
        WHERE id = p_ticket_id;
    END IF;

-- Log the actual deletion or closure event
    INSERT INTO Fproject.event_store(event_type, aggregate_type, aggregate_id, payload, user_id, wbi)
    VALUES (
               CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'ticket_deletion' ELSE 'ticket_closure' END,
               'ticket',
               p_ticket_id,
               -- Use jsonb_build_object to ensure the payload is of type JSON
               jsonb_build_object(
                       'action',
                       CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'ticket_deletion' ELSE 'ticket_closure' END,
                       'details',
                       jsonb_build_object('action', CASE WHEN (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_created_at)) / 60) <= 2 THEN 'ticket_deletion' ELSE 'ticket_closure' END)
               ),
               p_user_id,
               v_user_wbi
           );
END;
$$
;



-- Stored procedure to get all tickets for a user based on their role
CREATE OR REPLACE FUNCTION Fproject.get_user_tickets(p_user_id INT)
    RETURNS TABLE(
                     ticket_id INT,
                     subject VARCHAR,
                     content TEXT,
                     status_name VARCHAR,
                     priority_name VARCHAR,
                     category_name VARCHAR,
                     created_at TIMESTAMP,
                     updated_at TIMESTAMP,
                     completed_at TIMESTAMP,
                     requester_name VARCHAR,
                     requester_position VARCHAR,
                     assigned_to_name VARCHAR,
                     attachment BYTEA,
                     permission_required VARCHAR,
                     requester_employment_status VARCHAR,
                     attachment_name VARCHAR,
                     attachment_type VARCHAR,
                     wbi VARCHAR,
                     requester_email VARCHAR
                 ) AS $$
DECLARE
    user_role VARCHAR;
BEGIN
    -- Determine the role of the user
    SELECT r.role_name INTO user_role
    FROM Fproject."user" u
             JOIN Fproject.role r ON u.role_id = r.id
    WHERE u.id = p_user_id;

    IF user_role = 'Administrator' THEN
        RETURN QUERY
            SELECT t.id AS ticket_id,
                   t.subject,
                   t.content,
                   ts.status_name,
                   tp.priority_name,
                   c.category_name,
                   t.created_at,
                   t.updated_at,
                   t.completed_at,
                   (SELECT (u2.f_name || ' ' || u2.l_name)::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_name,
                   (SELECT pos.pos_name FROM Fproject.position pos WHERE pos.id = t.requested_position) AS requester_position,
                   (SELECT (u3.f_name || ' ' || u3.l_name)::VARCHAR FROM Fproject."user" u3 WHERE u3.id = t.assigned_to) AS assigned_to_name,
                   t.attachment,
                   (SELECT p.permission_name FROM Fproject.permissions p WHERE p.id = t.permission_required) AS permission_required,
                   (SELECT es.employment_name FROM Fproject."user" u JOIN Fproject.employment_status es ON u.employment_status_id = es.id WHERE u.id = t.user_id) AS requester_employment_status,
                   t.attachment_name,
                   t.attachment_type,
                   (SELECT u2.wbi::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS wbi,
                   (SELECT u2.email::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_email
            FROM Fproject.ticket t
                     JOIN Fproject.ticket_status ts ON t.status_id = ts.id
                     JOIN Fproject.ticket_priorities tp ON t.priority_id = tp.id
                     JOIN Fproject.categories c ON t.category_id = c.category_id;

    ELSIF user_role = 'Manager' THEN
        RETURN QUERY
            SELECT t.id AS ticket_id,
                   t.subject,
                   t.content,
                   ts.status_name,
                   tp.priority_name,
                   c.category_name,
                   t.created_at,
                   t.updated_at,
                   t.completed_at,
                   (SELECT (u2.f_name || ' ' || u2.l_name)::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_name,
                   (SELECT pos.pos_name FROM Fproject.position pos WHERE pos.id = t.requested_position) AS requester_position,
                   (SELECT (u3.f_name || ' ' || u3.l_name)::VARCHAR FROM Fproject."user" u3 WHERE u3.id = t.assigned_to) AS assigned_to_name,
                   t.attachment,
                   (SELECT p.permission_name FROM Fproject.permissions p WHERE p.id = t.permission_required) AS permission_required,
                   (SELECT es.employment_name FROM Fproject."user" u JOIN Fproject.employment_status es ON u.employment_status_id = es.id WHERE u.id = t.user_id) AS requester_employment_status,
                    t.attachment_name,
                    t.attachment_type,
                   (SELECT u2.wbi::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS wbi,
                   (SELECT u2.email::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_email
            FROM Fproject.ticket t
                     JOIN Fproject.ticket_status ts ON t.status_id = ts.id
                     JOIN Fproject.ticket_priorities tp ON t.priority_id = tp.id
                     JOIN Fproject.categories c ON t.category_id = c.category_id
            WHERE t.category_id IN (
                SELECT category_id
                FROM Fproject.user_categories uc
                WHERE uc.user_id = p_user_id
            );

    ELSE
        RETURN QUERY
            SELECT t.id AS ticket_id,
                   t.subject,
                   t.content,
                   ts.status_name,
                   tp.priority_name,
                   c.category_name,
                   t.created_at,
                   t.updated_at,
                   t.completed_at,
                   (SELECT (u2.f_name || ' ' || u2.l_name)::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_name,
                   (SELECT pos.pos_name FROM Fproject.position pos WHERE pos.id = t.requested_position) AS requester_position,
                   (SELECT (u3.f_name || ' ' || u3.l_name)::VARCHAR FROM Fproject."user" u3 WHERE u3.id = t.assigned_to) AS assigned_to_name,
                   t.attachment,
                   (SELECT p.permission_name FROM Fproject.permissions p WHERE p.id = t.permission_required) AS permission_required,
                   (SELECT es.employment_name FROM Fproject."user" u JOIN Fproject.employment_status es ON u.employment_status_id = es.id WHERE u.id = t.user_id) AS requester_employment_status,
                   t.attachment_name,
                   t.attachment_type,
                   (SELECT u2.wbi::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS wbi,
                   (SELECT u2.email::VARCHAR FROM Fproject."user" u2 WHERE u2.id = t.user_id) AS requester_email
            FROM Fproject.ticket t
                     JOIN Fproject.ticket_status ts ON t.status_id = ts.id
                     JOIN Fproject.ticket_priorities tp ON t.priority_id = tp.id
                     JOIN Fproject.categories c ON t.category_id = c.category_id
            WHERE t.user_id = p_user_id;
    END IF;
END;
$$

    LANGUAGE plpgsql;

--drop function Fproject.get_user_tickets;

select * from Fproject.get_user_tickets(1);

CREATE OR REPLACE FUNCTION Fproject.get_ticket_options()
    RETURNS TABLE (
                      option_type VARCHAR,
                      option_value VARCHAR,
                      option_label VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT CAST('position' AS VARCHAR) AS option_type, pos_name AS option_value, pos_name AS option_label
        FROM Fproject.position
        UNION ALL
        SELECT CAST('permission_required' AS VARCHAR), permission_name, permission_name
        FROM Fproject.permissions
        UNION ALL
        SELECT CAST('employment_status' AS VARCHAR), employment_name, employment_name
        FROM Fproject.employment_status
        UNION ALL
        SELECT CAST('ticket_manager' AS VARCHAR), CONCAT(u.f_name, ' ', u.l_name), CONCAT(u.f_name, ' ', u.l_name)
        FROM Fproject."user" u
                 JOIN Fproject.role r ON u.role_id = r.id
        WHERE r.role_name = 'Manager'
        UNION ALL
        SELECT CAST('required_category' AS VARCHAR), category_name, category_name
        FROM Fproject.categories
        UNION ALL
        SELECT CAST('ticket_status' AS VARCHAR), status_name, status_name
        FROM Fproject.ticket_status
        UNION ALL
        SELECT CAST('ticket_priority' AS VARCHAR), priority_name, priority_name
        FROM Fproject.ticket_priorities;
END;
$$

    LANGUAGE plpgsql;

select * from Fproject.get_ticket_options();


CREATE OR REPLACE FUNCTION Fproject.get_wbi_by_user_id(p_user_id INT)
    RETURNS VARCHAR AS $$
DECLARE
    v_wbi VARCHAR;
BEGIN
    SELECT WBI INTO v_wbi FROM Fproject."user" WHERE id = p_user_id;
    RETURN v_wbi;
END;
$$
LANGUAGE plpgsql;