
CREATE TABLE user_detail (
    id serial PRIMARY KEY,
    username VARCHAR(69) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

INSERT INTO user_detail (username, password) VALUES ('admin', 'BO0');
INSERT INTO user_detail (username, password) VALUES ('user', 'BO1');
INSERT INTO user_detail (username, password) VALUES ('guest', 'BO2');

SELECT * FROM user_detail;

