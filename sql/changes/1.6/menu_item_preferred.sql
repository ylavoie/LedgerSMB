DROP TYPE IF EXISTS menu_item CASCADE;
CREATE TYPE menu_item AS (
   position int,
   id int,
   level int,
   label varchar,
   path varchar,
   parent int,
   args text[],
   preferred boolean,
   children int[]
);

ALTER TABLE user_preference
    ADD COLUMN menus int[];