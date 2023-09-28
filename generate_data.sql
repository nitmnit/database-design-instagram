--- Change the value here to decide the number of entries to be inserted
TRUNCATE "user" CASCADE;
TRUNCATE "user_profile" CASCADE;
TRUNCATE "story" CASCADE;
TRUNCATE "media" CASCADE;
TRUNCATE "media_story_map" CASCADE;
TRUNCATE "slike" CASCADE;

DO $$
    DECLARE num_users BIGINT DEFAULT 10; -- Set number of users to create here
    avg_stories_per_user INT DEFAULT 50;
    avg_medias_per_story INT DEFAULT 3;
    media_id BIGINT;
    story_id BIGINT;
BEGIN
    FOR user_id in 1..num_users loop RAISE NOTICE 'User ID: %', user_id;
        --- User
        INSERT INTO
            "user" (id, username, email, mobile, password_hash)
        SELECT
            user_id,
            left(md5((user_id) :: text), 20),
            concat(left(md5((user_id) :: text), 20), '@gmail.com'),
            floor(random() * 9000000000 + 1000000000),
            md5((user_id) :: text);

        --- User profile
        INSERT INTO
            "user_profile" (profile_picture_url, bio, gender)
        SELECT
            'https://wallpapers.com/images/high/david-goggins-inspiring-artwork-r4vlpgz0shtazu6q.webp',
            md5((user_id) :: text),
            ('{"male", "female", "other"}' :: VARCHAR []) [((random() * 10)::INT % 3)::INT + 1];

        -- Story
        FOR story_index in 1..avg_stories_per_user loop
            story_id = (user_id - 1) * avg_stories_per_user + story_index;
            INSERT INTO
                "story" (id, user_id, caption)
            SELECT
                story_id,
                user_id,
                md5((story_id) :: text);

            --- Medias
            FOR media in 1..avg_medias_per_story loop
                media_id = (user_id * story_id - 1) * avg_medias_per_story + media;

                RAISE NOTICE 'media: %, user_id: %, story_id: %',
                media_id,
                user_id,
                story_id;

                INSERT INTO
                    "media" (id, media_url)
                SELECT
                    media_id,
                    md5(media_id :: text);

                --- Media Story Map
                INSERT INTO
                    "media_story_map" (story_id, media_id, "order")
                SELECT
                    story_id,
                    media_id,
                    media;

            END LOOP;
        END loop;

        IF user_id % 1000 = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    COMMIT;
END $$;

SELECT
    *
FROM
    "user";

--- TODO Merge all transactions into one having multiple commit points