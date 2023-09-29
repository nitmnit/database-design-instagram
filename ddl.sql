DROP DATABASE IF EXISTS instagram;

CREATE DATABASE instagram;

CREATE TABLE "user" (
    id bigserial PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    email varchar(255) NOT NULL UNIQUE,
    mobile varchar(16) UNIQUE,
    password_hash varchar(255),
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE user_profile (
    user_id BIGINT REFERENCES "user" NOT NULL PRIMARY KEY,
    profile_picture_url varchar(255),
    bio text,
    gender varchar(16),
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE media (
    id bigserial PRIMARY KEY,
    media_url varchar(255) NOT NULL UNIQUE
);

CREATE TABLE story (
    id bigserial PRIMARY KEY,
    user_id bigint references "user" ON DELETE CASCADE,
    caption text,
    is_reel boolean DEFAULT false,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);
CREATE INDEX CONCURRENTLY idx_story_user_id ON story(user_id);

CREATE TABLE media_story_map(
    id bigserial PRIMARY KEY,
    story_id bigint NOT NULL references story ON DELETE CASCADE,
    media_id bigint NOT NULL references media ON DELETE RESTRICT,
    "order" smallint NOT NULL,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE slike (
    story_id bigint NOT NULL references story ON DELETE CASCADE,
    user_id bigint NOT NULL references "user" ON DELETE CASCADE,
    PRIMARY KEY (story_id, user_id)
);
CREATE INDEX CONCURRENTLY idx_slike_user_id ON slike(user_id);

CREATE TABLE comment (
    id bigserial PRIMARY KEY,
    comment text NOT NULL,
    story_id bigint NOT NULL references story ON DELETE CASCADE,
    user_id bigint NOT NULL references "user" ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE reply (
    id bigserial PRIMARY KEY,
    comment text NOT NULL,
    parent_comment_id bigint NOT NULL references comment ON DELETE CASCADE,
    user_id bigint NOT NULL references "user" ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE follow (
    id bigserial PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    follows_user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX CONCURRENTLY idx_follow_user_id ON follow(user_id);

CREATE TABLE bookmarks (
    user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    story_id bigint NOT NULL REFERENCES story ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, story_id)
);

CREATE OR REPLACE FUNCTION random_between(low BIGINT, high BIGINT)
RETURNS BIGINT AS
$$
BEGIN
    return FLOOR(random() * (high - low + 1) + low)::BIGINT;
END;
$$ LANGUAGE plpgsql;
