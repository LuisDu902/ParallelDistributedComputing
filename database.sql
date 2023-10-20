CREATE SCHEMA IF NOT EXISTS gameon;

SET DateStyle TO European;

-----------
-- Drop tables
-----------

DROP TABLE IF EXISTS question_tag;
DROP TABLE IF EXISTS game_member;
DROP TABLE IF EXISTS user_badge;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS version_content;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS vote;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS answer;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS game_section;
DROP TABLE IF EXISTS badge;
DROP TABLE IF EXISTS banned;
DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS "user";

-----------
-- Types
-----------

CREATE TYPE Rank AS ENUM ('bronze', 'gold', 'master');
CREATE TYPE Badge_type AS ENUM ('badge1', 'badge2');
CREATE TYPE Notification_type AS ENUM ('report_notification', 'rank_notification', 'badge_notification', 'answer_notification', 'question_notification', 'comment_notification', 'vote_notification');
CREATE TYPE Report_type AS ENUM ('question_report', 'answer_report', 'comment_report');
CREATE TYPE Vote_type AS ENUM ('question_vote', 'answer_vote');
CREATE TYPE Content_type AS ENUM ('question_content', 'answer_content', 'comment_content');

-----------
-- Tables
-----------

CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    username VARCHAR(256) UNIQUE NOT NULL,
    email VARCHAR(256) UNIQUE NOT NULL,
    password VARCHAR(256) NOT NULL,
    description TEXT,
    rank Rank NOT NULL DEFAULT 'bronze'
);

CREATE TABLE admin (
    user_id INTEGER PRIMARY KEY REFERENCES "user"(id)
);

CREATE TABLE banned (
    user_id INTEGER PRIMARY KEY REFERENCES "user"(id)
);

CREATE TABLE badge (
    id SERIAL PRIMARY KEY,
    type Badge_type NOT NULL
);

CREATE TABLE game_section (
    id SERIAL PRIMARY KEY,
    type VARCHAR(256) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE game (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256) UNIQUE NOT NULL,
    description TEXT,
    nr_members INTEGER NOT NULL CHECK (nr_members >= 0),
    game_section_id INTEGER NOT NULL REFERENCES game_section(id)
);

CREATE TABLE question (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    create_date TIMESTAMP NOT NULL CHECK (create_date <= now()),
    title VARCHAR(256) NOT NULL,
    is_solved BOOLEAN NOT NULL DEFAULT False,
    is_public BOOLEAN NOT NULL DEFAULT True,
    nr_views INTEGER NOT NULL CHECK (nr_views >= 0),
    nr_votes INTEGER NOT NULL CHECK (nr_votes >= 0),
    game_id INTEGER REFERENCES game(id)
);

CREATE TABLE comment (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    question_id INTEGER NOT NULL REFERENCES question(id),
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    is_public BOOLEAN NOT NULL DEFAULT True
);

CREATE TABLE answer (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    question_id INTEGER NOT NULL REFERENCES question(id),
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    is_public BOOLEAN NOT NULL DEFAULT True,
    top_answer BOOLEAN NOT NULL DEFAULT False,
    nr_votes INTEGER NOT NULL CHECK (nr_votes >= 0)
);

CREATE TABLE vote (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    feedback BOOLEAN NOT NULL,
    vote_type Vote_type NOT NULL,
    answer_id INTEGER,
    question_id INTEGER,
    CHECK (
        (vote_type = 'question_vote' AND question_id IS NOT NULL AND answer_id IS NULL) OR
        (vote_type = 'answer_vote' AND answer_id IS NOT NULL AND question_id IS NULL)
    ),
    FOREIGN KEY (answer_id) REFERENCES answer(id),
    FOREIGN KEY (question_id) REFERENCES question(id)
);


CREATE TABLE tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256) UNIQUE NOT NULL
);

CREATE TABLE version_content (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    content TEXT NOT NULL,
    content_type Content_type NOT NULL,
    question_id INTEGER,
    answer_id INTEGER,
    comment_id INTEGER REFERENCES comment(id),
    CHECK (
        (content_type = 'question_content' AND question_id IS NOT NULL AND answer_id IS NULL AND comment_id IS NULL) OR
        (content_type = 'answer_content' AND answer_id IS NOT NULL AND question_id IS NULL AND comment_id IS NULL) OR
        (content_type = 'comment_content' AND comment_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL)
    ),
    FOREIGN KEY (question_id) REFERENCES question(id),
    FOREIGN KEY (answer_id) REFERENCES answer(id)
);


CREATE TABLE report (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    reason TEXT NOT NULL,
    is_solved BOOLEAN NOT NULL DEFAULT False,
    reporter_id INTEGER NOT NULL REFERENCES "user"(id),
    reported_id INTEGER NOT NULL REFERENCES "user"(id),
    report_type Report_type NOT NULL,
    question_id INTEGER REFERENCES question(id),
    answer_id INTEGER REFERENCES answer(id),
    comment_id INTEGER REFERENCES comment(id),
    CHECK (
        (report_type = 'question_report' AND question_id IS NOT NULL AND answer_id IS NULL AND comment_id IS NULL) OR
        (report_type = 'answer_report' AND answer_id IS NOT NULL AND question_id IS NULL AND comment_id IS NULL) OR
        (report_type = 'comment_report' AND comment_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL)
    )
);

CREATE TABLE notification (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL CHECK (date <= now()),
    viewed BOOLEAN NOT NULL DEFAULT False,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    notification_type Notification_type NOT NULL,
    question_id INTEGER REFERENCES question(id),
    answer_id INTEGER REFERENCES answer(id),
    comment_id INTEGER REFERENCES comment(id),
    vote_id INTEGER REFERENCES vote(id),
    report_id INTEGER REFERENCES report(id),
    CHECK (
        (notification_type = 'report_notification' AND report_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL) OR
        (notification_type = 'question_notification' AND question_id IS NOT NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL) OR
        (notification_type = 'answer_notification' AND answer_id IS NOT NULL AND report_id IS NULL AND question_id IS NULL AND comment_id IS NULL AND vote_id IS NULL) OR
        (notification_type = 'comment_notification' AND comment_id IS NOT NULL AND report_id IS NULL AND answer_id IS NULL AND question_id IS NULL AND vote_id IS NULL) OR
        (notification_type = 'vote_notification' AND vote_id IS NOT NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND question_id IS NULL) OR
        (notification_type = 'rank_notification' AND question_id IS NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL) OR
        (notification_type = 'badge_notification' AND question_id IS NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL)
    )
);

CREATE TABLE user_badge (
    user_id INTEGER REFERENCES "user"(id),
    badge_id INTEGER REFERENCES badge(id),
    PRIMARY KEY (user_id, badge_id)
);

CREATE TABLE game_member (
    user_id INTEGER REFERENCES "user"(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (user_id, game_id)
);

CREATE TABLE question_tag (
    question_id INTEGER REFERENCES question(id),
    tag_id INTEGER REFERENCES tag(id),
    PRIMARY KEY (question_id, tag_id)
);


--Trigger 1

CREATE OR REPLACE FUNCTION update_question_vote_count_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.feedback = TRUE THEN
    UPDATE question
    SET nr_votes = nr_votes + 1
    WHERE id = NEW.question_id;
  ELSE
    UPDATE question
    SET nr_votes = nr_votes - 1
    WHERE id = NEW.question_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_vote_count_trigger
AFTER INSERT ON vote
FOR EACH ROW
EXECUTE FUNCTION update_question_vote_count_trigger_function();


--Trigger 2

CREATE OR REPLACE FUNCTION prevent_self_upvote_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.vote_type = 'question_vote' THEN
    IF NEW.question_id IS NOT NULL AND NEW.user_id = (SELECT user_id FROM question WHERE id = NEW.question_id) THEN
      RAISE EXCEPTION 'You cannot upvote your own question.';
    END IF;
  END IF;
  
  IF NEW.vote_type = 'answer_vote' THEN
    IF NEW.answer_id IS NOT NULL AND NEW.user_id = (SELECT user_id FROM answer WHERE id = NEW.answer_id) THEN
      RAISE EXCEPTION 'You cannot upvote your own answer.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_self_upvote_trigger
BEFORE INSERT ON vote
FOR EACH ROW
EXECUTE FUNCTION prevent_self_upvote_trigger_function();




---Trigger 3

CREATE OR REPLACE FUNCTION delete_question_cascade_votes_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM vote WHERE question_id = OLD.id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_question_cascade_votes_trigger
AFTER DELETE ON question
FOR EACH ROW
EXECUTE FUNCTION delete_question_cascade_votes_trigger_function();



---Trigger 4

CREATE OR REPLACE FUNCTION update_question_privacy_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM banned WHERE user_id = NEW.user_id) > 0 THEN
    UPDATE question
    SET is_public = FALSE
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_privacy_trigger
AFTER INSERT ON banned
FOR EACH ROW
EXECUTE FUNCTION update_question_privacy_trigger_function();

---POPULATE




INSERT INTO "user" (id, name, username, email, password, description, rank)
VALUES
  (1,
   'John Doe',               
   'johndoe',                
   'johndoe@example.com',    
   'hashed_password',       
   'Some description',       
   'bronze');                




INSERT INTO "banned" (user_id)
VALUES (1);                



INSERT INTO question (user_id, create_date, title, is_solved, is_public, nr_views, nr_votes)
VALUES (
    1,                   
    NOW(),               
    'Sample Question',   
    TRUE,               
    TRUE,                
    100,                 
    0                   
);



INSERT INTO vote (user_id, date, feedback, vote_type, answer_id, question_id)
SELECT
    
    1,
    
    '2023-10-19 14:30:00',
  
    TRUE,
   
    'question_vote',
    
    NULL,
   
    1
FROM generate_series(1, 100); 






