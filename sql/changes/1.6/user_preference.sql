BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema='public'
          AND table_name='user_preference'
          AND column_name='timesheetframe')
    THEN
        ALTER TABLE user_preference ADD COLUMN timesheetframe text DEFAULT 'Week' NOT NULL;
    ELSE
        ALTER TABLE user_preference ALTER COLUMN timesheetframe TYPE text;
        ALTER TABLE user_preference ALTER COLUMN timesheetframe SET DEFAULT 'Week';
        UPDATE user_preference SET timesheetframe = 'Week'
        WHERE timesheetframe IS NULL;
        ALTER TABLE user_preference ALTER COLUMN timesheetframe SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema='public'
          AND table_name='user_preference'
          AND column_name='timesheettype')
    THEN
        ALTER TABLE user_preference ADD COLUMN timesheettype text DEFAULT 'Time' NOT NULL;
    ELSE
        ALTER TABLE user_preference ALTER COLUMN timesheettype TYPE text;
        ALTER TABLE user_preference ALTER COLUMN timesheettype SET DEFAULT 'Time';
        UPDATE user_preference SET timesheettype = 'Time'
        WHERE timesheettype IS NULL;
    END IF;

    IF NOT EXISTS (
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema='public'
          AND table_name='user_preference'
          AND column_name='timesheetunit')
    THEN
        ALTER TABLE user_preference ADD COLUMN timesheetunit int DEFAULT 1;
    ELSE
        ALTER TABLE user_preference ALTER COLUMN timesheetunit TYPE int;
        ALTER TABLE user_preference ALTER COLUMN timesheetunit SET DEFAULT 1;
        UPDATE user_preference SET timesheetunit = 1
        WHERE timesheetunit IS NULL;
    END IF;

END $$;

COMMIT;
