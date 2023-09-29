--- Change the value here to decide the number of entries to be inserted
TRUNCATE "user" CASCADE;
TRUNCATE "user_profile" CASCADE;
TRUNCATE "story" CASCADE;
TRUNCATE "media" CASCADE;
TRUNCATE "media_story_map" CASCADE;
TRUNCATE "slike" CASCADE;
TRUNCATE "comment" CASCADE;
TRUNCATE "reply" CASCADE;

DO $$
    DECLARE num_users BIGINT DEFAULT 10000; -- Set number of users to create here
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


-- slike Table generate data
DO $$
DECLARE
    num_users BIGINT DEFAULT 10000; -- Set number of users to create here
    story_cursor CURSOR FOR
        SELECT id as story_id
        FROM story;
    story_id BIGINT;
    max_user_percent_likes INT DEFAULT 1;
    max_user_percent_comments INT DEFAULT 1;
    total_user_likes BIGINT;
    total_user_comments BIGINT;
    likes_progress BIGINT DEFAULT 0;
    comment_progress BIGINT DEFAULT 0;
    user_id BIGINT;
	like_cnt BIGINT DEFAULT 0;
	comment_cnt BIGINT DEFAULT 0;
BEGIN
    OPEN story_cursor;
    LOOP
        FETCH story_cursor INTO story_id;
        EXIT WHEN NOT FOUND;

        -- likes
        like_cnt = 0;
        total_user_likes = random_between(0, num_users * max_user_percent_likes / 100);
		WHILE like_cnt < total_user_likes LOOP
            user_id = random_between(1, num_users);
			BEGIN
				INSERT INTO "slike" (story_id, user_id)
				SELECT story_id, user_id;
				likes_progress = likes_progress + 1;
				like_cnt = like_cnt + 1;
            EXCEPTION 
                WHEN unique_violation THEN
                CONTINUE;
			END;
		END LOOP;

        -- comments
        comment_cnt = 0;
        total_user_comments = random_between(1, num_users * max_user_percent_comments / 100);
		WHILE comment_cnt < total_user_comments LOOP
            user_id = random_between(1, num_users);
			BEGIN
				INSERT INTO "comment" (comment, story_id, user_id)
				SELECT 'Stay Hard!', story_id, user_id;
				comment_progress = comment_progress + 1;
				comment_cnt = comment_cnt + 1;
            EXCEPTION 
                WHEN unique_violation THEN
                CONTINUE;
			END;
		END LOOP;

		IF story_id % 1000 = 0 THEN
            RAISE NOTICE 'likes_progress: %', likes_progress;
            RAISE NOTICE 'comments progress: %', comment_progress;
            COMMIT;
        END IF;
    END LOOP;
	RAISE NOTICE 'llikes_progress: %', likes_progress;
	RAISE NOTICE 'ccomment_progress: %', comment_progress;
END $$;


--- Replies
DO $$
DECLARE
    num_users BIGINT DEFAULT 10000; -- Set number of users to create here
    comment_cursor CURSOR FOR
        SELECT id as comment_id
        FROM comment;
    comment_id BIGINT;
    max_comment_percent_replies INT DEFAULT 1;
    replies_progress BIGINT DEFAULT 0;
    user_id BIGINT;
	reply_cnt BIGINT DEFAULT 0;
BEGIN
    OPEN comment_cursor;
    LOOP
        FETCH comment_cursor INTO comment_id;
        EXIT WHEN NOT FOUND;
        IF random() > max_comment_percent_replies / 100 THEN
            CONTINUE;
        END IF;
        reply_cnt = 0;
		WHILE reply_cnt < 10 LOOP
            user_id = random_between(1, num_users);
			BEGIN
				INSERT INTO "reply" (comment, parent_comment_id, user_id)
				SELECT "reply comment", comment_id, user_id;
				replies_progress = replies_progress + 1;
				reply_cnt = reply_cnt + 1;
            EXCEPTION 
                WHEN unique_violation THEN
                CONTINUE;
			END;
		END LOOP;

		IF replies_progress % 1000 = 0 THEN
            RAISE NOTICE 'replies_progress: %', replies_progress;
            COMMIT;
        END IF;
    END LOOP;
    COMMIT;
	RAISE NOTICE 'rreplies_progress: %', replies_progress;
END $$;


--- Follow
--- Every user will have some followers, the distribution? 
1 - 30
2 - 29
3 - 27
10 - 20
20 - 10
30 - 1
50 - 1


DO $$
DECLARE
    num_users BIGINT;
    follow_percentage INT .3; -- 30%
    user_cursor CURSOR FOR SELECT id FROM "user";
    follower_cursor CURSOR FOR SELECT id FROM "user";
    user_progress BIGINT DEFAULT 0;
    progress_percent INT DEFAULT 0;
    user_id BIGINT;
    follower_id BIGINT;
    next_user_goal BIGINT;
BEGIN
    num_users = (SELECT COUNT(*) FROM "user");
    next_user_goal = num_users * .01;
    OPEN user_cursor;
    OPEN follower_cursor;
    LOOP
        MOVE ABSOLUTE 1 FROM follower_cursor;
        FETCH user_cursor INTO user_id;
        EXIT WHEN NOT FOUND;
        LOOP
            FETCH follower_cursor in follower_id;
            EXIT WHEN NOT FOUND;
            IF RANDOM() > follow_percentage THEN
                CONTINUE;
            END IF;
            INSERT INTO "follow" (user_id, follows_user_id) 
            SELECT follower_id, user_id;
        END LOOP;
        user_progress = user_progress+ 1;
        IF next_user_goal = user_progress THEN
            next_user_goal = next_user_goal + num_users * .01;
            follow_percentage = follow_percentage - .01;
        END IF;
    END LOOP;

END $$;


-- Follows
DO $$
DECLARE
    num_users BIGINT;
    follow_percentage FLOAT DEFAULT .3; -- 30%
    user_cursor CURSOR FOR SELECT id FROM "user";
    follower_cursor CURSOR FOR SELECT id FROM "user";
    user_progress BIGINT DEFAULT 0;
    progress_percent INT DEFAULT 0;
    user_id BIGINT;
    follower_id BIGINT;
    next_user_goal BIGINT;
BEGIN
    num_users = (SELECT COUNT(*) FROM "user");
    next_user_goal = num_users * .01;
    OPEN user_cursor;
    OPEN follower_cursor;
    LOOP
        FETCH user_cursor INTO user_id;
        EXIT WHEN NOT FOUND;

        MOVE ABSOLUTE 1 FROM follower_cursor;
        LOOP
            FETCH follower_cursor INTO follower_id;
            EXIT WHEN NOT FOUND;
            IF RANDOM() > follow_percentage THEN
                CONTINUE;
            END IF;
            INSERT INTO "follow" (user_id, follows_user_id) 
            SELECT follower_id, user_id;
        END LOOP;
        user_progress = user_progress+ 1;
        IF next_user_goal = user_progress THEN
            next_user_goal = next_user_goal + num_users * .01;
            follow_percentage = GREATEST(follow_percentage - .01, 1000);
           	progress_percent = user_progress * 100/ num_users;
           raise notice 'progress percentage: %', progress_percent;
        END IF;
    END LOOP;

END $$;