--- Fetch User profile for given user id
SELECT
    id,
    username,
    email,
    mobile,
    profile_picture_url,
    bio,
    gender
FROM
    "user" u
    INNER JOIN "user_profile" up on u.id = up.user_id
WHERE
    user_id = 6;

--- Fetch user ids of all users who are being followed by given user id
SELECT
    u.id
FROM
    "user" u
    INNER JOIN follow f ON u.id = f.follows_user_id
WHERE
    f.user_id = 6;

-- Last n Stories by User Y
SELECT
    id
FROM
    story s
WHERE
    s.user_id = 6
LIMIT
    100;

--- Fetch all liked posts by user
SELECT
    story_id
FROM
    slike s
where
    s.user_id = 6;

--- Fetch all saved posts by a user
SELECT
    story_id
FROM
    bookmarks b
where
    b.user_id = 6;

--- Total likes for a given story
SELECT
    COUNT(*)
FROM
    slike s
WHERE
    s.story_id = 1002;

--- Number of comments for a given story
SELECT
    COUNT(*)
FROM
    comment s
WHERE
    s.story_id = 1002;

--- All reels by user id
SELECT
    id
FROM
    story
WHERE
    is_reel
    AND user_id = 78;

--- Insert when user Likes a story
INSERT INTO
    slike (story_id, user_id)
VALUES
    (1002, 6);

--- Create a story
--- Reset the sequence since we added ids manually
SELECT
    setval(
        "public"."story_id_seq",
        (
            SELECT
                MAX(id)
            FROM
                story
        )
    );

INSERT INTO
    "story" (user_id, is_reel, caption)
VALUES
    (
        6,
        true,
        'My first reel'
    );