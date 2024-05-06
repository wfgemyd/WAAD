
CREATE TABLE user_detail (
    id serial PRIMARY KEY,
    username VARCHAR(69) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);


SELECT * FROM user_detail;

