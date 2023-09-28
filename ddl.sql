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
    id bigserial PRIMARY KEY,
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

CREATE TABLE media_story_map(
    id bigserial PRIMARY KEY,
    story_id bigint NOT NULL references story ON DELETE CASCADE,
    media_id bigint NOT NULL references media ON DELETE RESTRICT,
    "order" smallint NOT NULL,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE slike (
    id bigserial PRIMARY KEY,
    story_id bigint NOT NULL references story ON DELETE CASCADE,
    user_id bigint NOT NULL references "user" ON DELETE CASCADE
);

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

CREATE TABLE message_room (
    id bigserial PRIMARY KEY,
    name varchar(255),
    is_private boolean DEFAULT false
);

CREATE TABLE message_room_user_map (
    message_room_id bigint NOT NULL REFERENCES message_room ON DELETE CASCADE,
    user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    PRIMARY KEY (message_room_id, user_id)
);

CREATE TABLE message (
    id bigserial PRIMARY KEY,
    message text NOT NULL,
    from_user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    to_room_id bigint NOT NULL REFERENCES message_room ON DELETE CASCADE
);

CREATE TABLE follow (
    id bigserial PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    follows_user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bookmarks (
    user_id bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    story_id bigint NOT NULL REFERENCES story ON DELETE CASCADE,
    created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, story_id)
);
