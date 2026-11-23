-- Stray Supabase PostgreSQL full-schema snapshot v1.0.0.
-- Re-runnable baseline for a fresh Supabase project; not a forward migration.
-- Requires Supabase roles/auth schema and PostgreSQL 15+ (security_invoker views).
--
-- Identity/sync contract:
--   * uuid is the global row identity exchanged by local SQLite and server Postgres.
--   * Relationships use *_uuid columns. Syncable relations intentionally have no
--     REFERENCES constraints so out-of-order/partial offline sync can land.
--   * id is a server-only bigint primary/index key. Never sync, expose, or use it
--     in a relationship. Client reads use the *_client views below.
--   * created_by_uuid/reviewed_by_uuid are attribution only, not foreign keys;
--     the server/API stamps actor values from the authenticated session.
--   * Clients/sync handlers bump updated_at on every edit for last-write-wins.
--
-- Apply this snapshot to an empty Supabase database. CREATE IF NOT EXISTS makes
-- re-execution safe, but does not repair drift; use a new forward migration.

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_roles (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid        uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    user_uuid   uuid NOT NULL UNIQUE REFERENCES auth.users (id) ON DELETE CASCADE,
    role_key    text NOT NULL DEFAULT 'contributor'
                CHECK (role_key IN ('system_admin', 'administrator', 'moderator', 'contributor')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.pilot_settings (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid            uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    feature         text NOT NULL DEFAULT 'pilot',
    name            text NOT NULL,
    setting_value   jsonb NOT NULL,
    created_by_uuid uuid DEFAULT auth.uid(),
    updated_by_uuid uuid DEFAULT auth.uid(),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT pilot_settings_feature_name_unique UNIQUE (feature, name),
    CONSTRAINT pilot_settings_feature_length
        CHECK (char_length(btrim(feature)) BETWEEN 1 AND 80),
    CONSTRAINT pilot_settings_name_length
        CHECK (char_length(btrim(name)) BETWEEN 1 AND 120)
);

CREATE TABLE IF NOT EXISTS public.animals (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    species             text NOT NULL,
    display_name        text,
    description         text NOT NULL,
    photo_path          text,
    observed_at         timestamptz NOT NULL DEFAULT now(),
    area_label          text NOT NULL,
    public_latitude     numeric(5, 3),
    public_longitude    numeric(6, 3),
    moderation_status   text NOT NULL DEFAULT 'pending'
                        CHECK (moderation_status IN ('pending', 'approved', 'hidden', 'archived')),
    created_by_uuid     uuid DEFAULT auth.uid(),
    reviewed_by_uuid    uuid,
    reviewed_at         timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    archived_at         timestamptz,
    CONSTRAINT animals_species_length
        CHECK (char_length(btrim(species)) BETWEEN 1 AND 80),
    CONSTRAINT animals_description_length
        CHECK (char_length(btrim(description)) BETWEEN 1 AND 1000),
    CONSTRAINT animals_display_name_length
        CHECK (display_name IS NULL OR char_length(display_name) <= 120),
    CONSTRAINT animals_area_label_length
        CHECK (char_length(btrim(area_label)) BETWEEN 1 AND 160),
    CONSTRAINT animals_photo_path_length
        CHECK (photo_path IS NULL OR char_length(photo_path) <= 1024),
    CONSTRAINT animals_coordinate_pair
        CHECK ((public_latitude IS NULL) = (public_longitude IS NULL)),
    CONSTRAINT animals_latitude_range
        CHECK (public_latitude IS NULL OR public_latitude BETWEEN -90 AND 90),
    CONSTRAINT animals_longitude_range
        CHECK (public_longitude IS NULL OR public_longitude BETWEEN -180 AND 180),
    CONSTRAINT animals_archive_state
        CHECK ((moderation_status = 'archived') = (archived_at IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS public.animal_updates (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    animal_uuid         uuid NOT NULL,
    update_kind         text NOT NULL
                        CHECK (update_kind IN ('sighting', 'food_or_water', 'other_care', 'welfare_concern')),
    observed_at         timestamptz NOT NULL DEFAULT now(),
    moderation_status   text NOT NULL DEFAULT 'pending'
                        CHECK (moderation_status IN ('pending', 'approved', 'hidden', 'archived')),
    created_by_uuid     uuid DEFAULT auth.uid(),
    reviewed_by_uuid    uuid,
    reviewed_at         timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    archived_at         timestamptz,
    CONSTRAINT animal_updates_archive_state
        CHECK ((moderation_status = 'archived') = (archived_at IS NOT NULL))
);

CREATE TABLE IF NOT EXISTS public.listing_flags (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    animal_uuid         uuid NOT NULL,
    flag_kind           text NOT NULL
                        CHECK (flag_kind IN ('inaccurate', 'unsafe_location', 'duplicate', 'outdated', 'welfare_concern')),
    reporter_uuid       uuid DEFAULT auth.uid(),
    review_status       text NOT NULL DEFAULT 'open'
                        CHECK (review_status IN ('open', 'triaged', 'resolved', 'dismissed')),
    reviewed_by_uuid    uuid,
    reviewed_at         timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    archived_at         timestamptz
);

CREATE TABLE IF NOT EXISTS public.care_guides (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid                uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    species             text,
    title               text NOT NULL,
    body                text NOT NULL,
    moderation_status   text NOT NULL DEFAULT 'pending'
                        CHECK (moderation_status IN ('pending', 'approved', 'hidden', 'archived')),
    created_by_uuid     uuid DEFAULT auth.uid(),
    reviewed_by_uuid    uuid,
    reviewed_at         timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    archived_at         timestamptz,
    CONSTRAINT care_guides_species_length
        CHECK (species IS NULL OR char_length(btrim(species)) BETWEEN 1 AND 80),
    CONSTRAINT care_guides_title_length
        CHECK (char_length(btrim(title)) BETWEEN 1 AND 160),
    CONSTRAINT care_guides_body_length
        CHECK (char_length(btrim(body)) BETWEEN 1 AND 4000),
    CONSTRAINT care_guides_archive_state
        CHECK ((moderation_status = 'archived') = (archived_at IS NOT NULL))
);

-- Global UUIDs are the sync keys. id indexes remain server-local.
CREATE INDEX IF NOT EXISTS idx_animals_public_map
    ON public.animals (public_latitude, public_longitude)
    WHERE moderation_status = 'approved' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animals_species_live
    ON public.animals (species, updated_at DESC)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animals_creator_live
    ON public.animals (created_by_uuid, updated_at DESC)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animals_reviewer
    ON public.animals (reviewed_by_uuid);
CREATE INDEX IF NOT EXISTS idx_animals_review_queue
    ON public.animals (updated_at)
    WHERE moderation_status = 'pending' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animal_updates_animal_live
    ON public.animal_updates (animal_uuid, updated_at DESC)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animal_updates_creator_live
    ON public.animal_updates (created_by_uuid, updated_at DESC)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_animal_updates_reviewer
    ON public.animal_updates (reviewed_by_uuid);
CREATE INDEX IF NOT EXISTS idx_animal_updates_review_queue
    ON public.animal_updates (updated_at)
    WHERE moderation_status = 'pending' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_listing_flags_animal_status
    ON public.listing_flags (animal_uuid, review_status, created_at)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_listing_flags_reporter
    ON public.listing_flags (reporter_uuid);
CREATE INDEX IF NOT EXISTS idx_listing_flags_reviewer
    ON public.listing_flags (reviewed_by_uuid);
CREATE INDEX IF NOT EXISTS idx_listing_flags_review_queue
    ON public.listing_flags (review_status, created_at)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_care_guides_species_live
    ON public.care_guides (species, updated_at DESC)
    WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_care_guides_creator
    ON public.care_guides (created_by_uuid);
CREATE INDEX IF NOT EXISTS idx_care_guides_reviewer
    ON public.care_guides (reviewed_by_uuid);
CREATE INDEX IF NOT EXISTS idx_care_guides_review_queue
    ON public.care_guides (updated_at)
    WHERE moderation_status = 'pending' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_pilot_settings_creator
    ON public.pilot_settings (created_by_uuid);
CREATE INDEX IF NOT EXISTS idx_pilot_settings_updater
    ON public.pilot_settings (updated_by_uuid);

COMMENT ON COLUMN public.user_roles.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.pilot_settings.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.pilot_settings.setting_value IS
    'Non-secret pilot configuration only. Store credentials in a secret manager, never here.';
COMMENT ON TABLE public.pilot_settings IS
    'Server-managed settings; seed approved pilot values only. Aggregate reports must enforce the configured minimum group threshold.';
COMMENT ON COLUMN public.animals.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.animal_updates.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.listing_flags.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.care_guides.id IS
    'Server-only index key. Never sync, expose to clients, or reference from another table.';
COMMENT ON COLUMN public.animals.public_latitude IS
    'Approved public-area/landmark coordinate only; never store the raw sighting or contributor device location here.';
COMMENT ON COLUMN public.animals.public_longitude IS
    'Approved public-area/landmark coordinate only; never store the raw sighting or contributor device location here.';
COMMENT ON COLUMN public.animals.photo_path IS
    'Optional Supabase Storage object path. Bucket creation and Storage policies are configured separately.';
COMMENT ON COLUMN public.animals.created_by_uuid IS
    'Content attribution only; not a foreign key or user-activity log. Null on account deletion.';
COMMENT ON COLUMN public.animals.updated_at IS
    'Client change column for last-write-wins sync; every local/server edit must bump it.';

CREATE OR REPLACE FUNCTION public.current_app_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
    SELECT ur.role_key
    FROM public.user_roles AS ur
    WHERE ur.user_uuid = auth.uid()
    LIMIT 1
$function$;

CREATE OR REPLACE FUNCTION public.has_app_role(VARIADIC allowed_roles text[])
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles AS ur
        WHERE ur.user_uuid = auth.uid()
          AND ur.role_key = ANY (allowed_roles)
    )
$function$;

CREATE OR REPLACE FUNCTION public.assign_default_contributor_role()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
    INSERT INTO public.user_roles (user_uuid, role_key)
    VALUES (NEW.id, 'contributor')
    ON CONFLICT (user_uuid) DO NOTHING;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.detach_deleted_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
    UPDATE public.animals
       SET created_by_uuid = CASE WHEN created_by_uuid = OLD.id THEN NULL ELSE created_by_uuid END,
           reviewed_by_uuid = CASE WHEN reviewed_by_uuid = OLD.id THEN NULL ELSE reviewed_by_uuid END,
           updated_at = pg_catalog.clock_timestamp()
     WHERE created_by_uuid = OLD.id OR reviewed_by_uuid = OLD.id;

    UPDATE public.animal_updates
       SET created_by_uuid = CASE WHEN created_by_uuid = OLD.id THEN NULL ELSE created_by_uuid END,
           reviewed_by_uuid = CASE WHEN reviewed_by_uuid = OLD.id THEN NULL ELSE reviewed_by_uuid END,
           updated_at = pg_catalog.clock_timestamp()
     WHERE created_by_uuid = OLD.id OR reviewed_by_uuid = OLD.id;

    UPDATE public.listing_flags
       SET reporter_uuid = CASE WHEN reporter_uuid = OLD.id THEN NULL ELSE reporter_uuid END,
           reviewed_by_uuid = CASE WHEN reviewed_by_uuid = OLD.id THEN NULL ELSE reviewed_by_uuid END,
           updated_at = pg_catalog.clock_timestamp()
     WHERE reporter_uuid = OLD.id OR reviewed_by_uuid = OLD.id;

    UPDATE public.care_guides
       SET created_by_uuid = CASE WHEN created_by_uuid = OLD.id THEN NULL ELSE created_by_uuid END,
           reviewed_by_uuid = CASE WHEN reviewed_by_uuid = OLD.id THEN NULL ELSE reviewed_by_uuid END,
           updated_at = pg_catalog.clock_timestamp()
     WHERE created_by_uuid = OLD.id OR reviewed_by_uuid = OLD.id;

    UPDATE public.pilot_settings
       SET created_by_uuid = CASE WHEN created_by_uuid = OLD.id THEN NULL ELSE created_by_uuid END,
           updated_by_uuid = CASE WHEN updated_by_uuid = OLD.id THEN NULL ELSE updated_by_uuid END,
           updated_at = pg_catalog.clock_timestamp()
     WHERE created_by_uuid = OLD.id OR updated_by_uuid = OLD.id;

    RETURN OLD;
END;
$function$;

CREATE OR REPLACE FUNCTION public.stamp_moderation_attribution()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $function$
BEGIN
    IF NEW.moderation_status IS DISTINCT FROM OLD.moderation_status
       OR public.has_app_role('moderator', 'administrator', 'system_admin') THEN
        NEW.reviewed_by_uuid := auth.uid();
        NEW.reviewed_at := pg_catalog.clock_timestamp();
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.stamp_flag_review_attribution()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $function$
BEGIN
    IF NEW.review_status IS DISTINCT FROM OLD.review_status
       OR public.has_app_role('moderator', 'administrator', 'system_admin') THEN
        NEW.reviewed_by_uuid := auth.uid();
        NEW.reviewed_at := pg_catalog.clock_timestamp();
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.stamp_pilot_setting_updater()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $function$
BEGIN
    NEW.updated_by_uuid := auth.uid();
    RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS on_auth_user_created_assign_role ON auth.users;
CREATE TRIGGER on_auth_user_created_assign_role
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.assign_default_contributor_role();

DROP TRIGGER IF EXISTS on_auth_user_deleted_detach_attribution ON auth.users;
CREATE TRIGGER on_auth_user_deleted_detach_attribution
AFTER DELETE ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.detach_deleted_auth_user();

DROP TRIGGER IF EXISTS pilot_settings_stamp_updater ON public.pilot_settings;
CREATE TRIGGER pilot_settings_stamp_updater
BEFORE UPDATE ON public.pilot_settings
FOR EACH ROW EXECUTE FUNCTION public.stamp_pilot_setting_updater();

INSERT INTO public.user_roles (user_uuid, role_key)
SELECT id, 'contributor'
FROM auth.users
ON CONFLICT (user_uuid) DO NOTHING;

-- Bootstrap the first system administrator from a trusted SQL session only:
-- UPDATE public.user_roles SET role_key = 'system_admin'
-- WHERE user_uuid = '<auth.users.id>'::uuid;

DROP TRIGGER IF EXISTS animals_stamp_moderation ON public.animals;
CREATE TRIGGER animals_stamp_moderation
BEFORE UPDATE ON public.animals
FOR EACH ROW EXECUTE FUNCTION public.stamp_moderation_attribution();

DROP TRIGGER IF EXISTS animal_updates_stamp_moderation ON public.animal_updates;
CREATE TRIGGER animal_updates_stamp_moderation
BEFORE UPDATE ON public.animal_updates
FOR EACH ROW EXECUTE FUNCTION public.stamp_moderation_attribution();

DROP TRIGGER IF EXISTS care_guides_stamp_moderation ON public.care_guides;
CREATE TRIGGER care_guides_stamp_moderation
BEFORE UPDATE ON public.care_guides
FOR EACH ROW EXECUTE FUNCTION public.stamp_moderation_attribution();

DROP TRIGGER IF EXISTS listing_flags_stamp_review ON public.listing_flags;
CREATE TRIGGER listing_flags_stamp_review
BEFORE UPDATE ON public.listing_flags
FOR EACH ROW EXECUTE FUNCTION public.stamp_flag_review_attribution();

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pilot_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animal_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.care_guides ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_roles_select_self_or_system_admin ON public.user_roles;
CREATE POLICY user_roles_select_self_or_system_admin
ON public.user_roles FOR SELECT TO authenticated
USING (user_uuid = auth.uid() OR public.has_app_role('system_admin'));

DROP POLICY IF EXISTS user_roles_update_system_admin ON public.user_roles;
CREATE POLICY user_roles_update_system_admin
ON public.user_roles FOR UPDATE TO authenticated
USING (public.has_app_role('system_admin'))
WITH CHECK (public.has_app_role('system_admin'));

DROP POLICY IF EXISTS pilot_settings_select_admin ON public.pilot_settings;
CREATE POLICY pilot_settings_select_admin
ON public.pilot_settings FOR SELECT TO authenticated
USING (public.has_app_role('administrator', 'system_admin'));

DROP POLICY IF EXISTS pilot_settings_insert_admin ON public.pilot_settings;
CREATE POLICY pilot_settings_insert_admin
ON public.pilot_settings FOR INSERT TO authenticated
WITH CHECK (
    created_by_uuid = auth.uid()
    AND public.has_app_role('administrator', 'system_admin')
);

DROP POLICY IF EXISTS pilot_settings_update_admin ON public.pilot_settings;
CREATE POLICY pilot_settings_update_admin
ON public.pilot_settings FOR UPDATE TO authenticated
USING (public.has_app_role('administrator', 'system_admin'))
WITH CHECK (public.has_app_role('administrator', 'system_admin'));

DROP POLICY IF EXISTS animals_select_visible ON public.animals;
CREATE POLICY animals_select_visible
ON public.animals FOR SELECT TO anon, authenticated
USING (
    (moderation_status = 'approved' AND archived_at IS NULL)
    OR (auth.uid() IS NOT NULL AND created_by_uuid = auth.uid())
    OR public.has_app_role('moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS animals_insert_contributor ON public.animals;
CREATE POLICY animals_insert_contributor
ON public.animals FOR INSERT TO authenticated
WITH CHECK (
    created_by_uuid = auth.uid()
    AND moderation_status = 'pending'
    AND archived_at IS NULL
    AND public.has_app_role('contributor', 'moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS animals_update_own_pending ON public.animals;
CREATE POLICY animals_update_own_pending
ON public.animals FOR UPDATE TO authenticated
USING (
    created_by_uuid = auth.uid()
    AND moderation_status = 'pending'
    AND archived_at IS NULL
)
WITH CHECK (created_by_uuid = auth.uid() AND moderation_status = 'pending');

DROP POLICY IF EXISTS animals_update_moderator ON public.animals;
CREATE POLICY animals_update_moderator
ON public.animals FOR UPDATE TO authenticated
USING (public.has_app_role('moderator', 'administrator', 'system_admin'))
WITH CHECK (public.has_app_role('moderator', 'administrator', 'system_admin'));

DROP POLICY IF EXISTS animal_updates_select_visible ON public.animal_updates;
CREATE POLICY animal_updates_select_visible
ON public.animal_updates FOR SELECT TO anon, authenticated
USING (
    (moderation_status = 'approved' AND archived_at IS NULL)
    OR (auth.uid() IS NOT NULL AND created_by_uuid = auth.uid())
    OR public.has_app_role('moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS animal_updates_insert_contributor ON public.animal_updates;
CREATE POLICY animal_updates_insert_contributor
ON public.animal_updates FOR INSERT TO authenticated
WITH CHECK (
    created_by_uuid = auth.uid()
    AND moderation_status = 'pending'
    AND archived_at IS NULL
    AND public.has_app_role('contributor', 'moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS animal_updates_update_moderator ON public.animal_updates;
CREATE POLICY animal_updates_update_moderator
ON public.animal_updates FOR UPDATE TO authenticated
USING (public.has_app_role('moderator', 'administrator', 'system_admin'))
WITH CHECK (public.has_app_role('moderator', 'administrator', 'system_admin'));

DROP POLICY IF EXISTS listing_flags_select_moderator ON public.listing_flags;
CREATE POLICY listing_flags_select_moderator
ON public.listing_flags FOR SELECT TO authenticated
USING (public.has_app_role('moderator', 'administrator', 'system_admin'));

DROP POLICY IF EXISTS listing_flags_insert_guest_or_user ON public.listing_flags;
-- Anonymous flags need API/gateway rate limiting; do not persist IP/device identifiers.
CREATE POLICY listing_flags_insert_guest_or_user
ON public.listing_flags FOR INSERT TO anon, authenticated
WITH CHECK (
    reporter_uuid IS NOT DISTINCT FROM auth.uid()
    AND review_status = 'open'
    AND archived_at IS NULL
);

DROP POLICY IF EXISTS listing_flags_update_moderator ON public.listing_flags;
CREATE POLICY listing_flags_update_moderator
ON public.listing_flags FOR UPDATE TO authenticated
USING (public.has_app_role('moderator', 'administrator', 'system_admin'))
WITH CHECK (public.has_app_role('moderator', 'administrator', 'system_admin'));

DROP POLICY IF EXISTS care_guides_select_visible ON public.care_guides;
CREATE POLICY care_guides_select_visible
ON public.care_guides FOR SELECT TO anon, authenticated
USING (
    (moderation_status = 'approved' AND archived_at IS NULL)
    OR public.has_app_role('moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS care_guides_insert_moderator ON public.care_guides;
CREATE POLICY care_guides_insert_moderator
ON public.care_guides FOR INSERT TO authenticated
WITH CHECK (
    created_by_uuid = auth.uid()
    AND moderation_status = 'pending'
    AND archived_at IS NULL
    AND public.has_app_role('moderator', 'administrator', 'system_admin')
);

DROP POLICY IF EXISTS care_guides_update_moderator ON public.care_guides;
CREATE POLICY care_guides_update_moderator
ON public.care_guides FOR UPDATE TO authenticated
USING (public.has_app_role('moderator', 'administrator', 'system_admin'))
WITH CHECK (public.has_app_role('moderator', 'administrator', 'system_admin'));

-- Read views omit server-only id and account-attribution columns. security_invoker
-- keeps the underlying table grants and RLS policies in force (Supabase PG 15+).
CREATE OR REPLACE VIEW public.animals_client
WITH (security_invoker = true)
AS
SELECT uuid, species, display_name, description, photo_path, observed_at,
       area_label, public_latitude, public_longitude, moderation_status,
       reviewed_at, created_at, updated_at, archived_at
FROM public.animals;

CREATE OR REPLACE VIEW public.animal_updates_client
WITH (security_invoker = true)
AS
SELECT uuid, animal_uuid, update_kind, observed_at, moderation_status,
       reviewed_at, created_at, updated_at, archived_at
FROM public.animal_updates;

CREATE OR REPLACE VIEW public.listing_flags_client
WITH (security_invoker = true)
AS
SELECT uuid, animal_uuid, flag_kind, review_status, reviewed_at,
       created_at, updated_at, archived_at
FROM public.listing_flags;

CREATE OR REPLACE VIEW public.care_guides_client
WITH (security_invoker = true)
AS
SELECT uuid, species, title, body, moderation_status,
       reviewed_at, created_at, updated_at, archived_at
FROM public.care_guides;

CREATE OR REPLACE VIEW public.user_roles_client
WITH (security_invoker = true)
AS
SELECT uuid, user_uuid, role_key, created_at, updated_at
FROM public.user_roles;

CREATE OR REPLACE VIEW public.pilot_settings_client
WITH (security_invoker = true)
AS
SELECT uuid, feature, name, setting_value, created_at, updated_at
FROM public.pilot_settings;

-- Do not grant table-wide SELECT: that would expose id and private attribution.
REVOKE ALL ON TABLE public.user_roles, public.pilot_settings, public.animals, public.animal_updates,
    public.listing_flags, public.care_guides FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.animals_client, public.animal_updates_client,
    public.listing_flags_client, public.care_guides_client,
    public.user_roles_client, public.pilot_settings_client FROM PUBLIC, anon, authenticated;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

GRANT SELECT (uuid, user_uuid, role_key, created_at, updated_at)
    ON public.user_roles TO authenticated;
GRANT UPDATE (role_key) ON public.user_roles TO authenticated;
GRANT SELECT (uuid, feature, name, setting_value, created_at, updated_at)
    ON public.pilot_settings TO authenticated;
GRANT INSERT (uuid, feature, name, setting_value, created_at, updated_at)
    ON public.pilot_settings TO authenticated;
GRANT UPDATE (setting_value, updated_at) ON public.pilot_settings TO authenticated;

GRANT SELECT (uuid, species, display_name, description, photo_path, observed_at,
              area_label, public_latitude, public_longitude, moderation_status,
              reviewed_at, created_at, updated_at, archived_at)
    ON public.animals TO anon, authenticated;
GRANT INSERT (uuid, species, display_name, description, photo_path, observed_at,
              area_label, public_latitude, public_longitude, created_at, updated_at)
    ON public.animals TO authenticated;
GRANT UPDATE (species, display_name, description, photo_path, observed_at,
              area_label, public_latitude, public_longitude, moderation_status,
              updated_at, archived_at)
    ON public.animals TO authenticated;

GRANT SELECT (uuid, animal_uuid, update_kind, observed_at, moderation_status,
              reviewed_at, created_at, updated_at, archived_at)
    ON public.animal_updates TO anon, authenticated;
GRANT INSERT (uuid, animal_uuid, update_kind, observed_at, created_at, updated_at)
    ON public.animal_updates TO authenticated;
GRANT UPDATE (moderation_status, updated_at, archived_at)
    ON public.animal_updates TO authenticated;

GRANT INSERT (uuid, animal_uuid, flag_kind, reporter_uuid, created_at, updated_at)
    ON public.listing_flags TO anon, authenticated;
GRANT SELECT (uuid, animal_uuid, flag_kind, review_status, reviewed_at,
              created_at, updated_at, archived_at)
    ON public.listing_flags TO authenticated;
GRANT UPDATE (review_status, updated_at, archived_at)
    ON public.listing_flags TO authenticated;

GRANT SELECT (uuid, species, title, body, moderation_status,
              reviewed_at, created_at, updated_at, archived_at)
    ON public.care_guides TO anon, authenticated;
GRANT INSERT (uuid, species, title, body, created_at, updated_at)
    ON public.care_guides TO authenticated;
GRANT UPDATE (species, title, body, moderation_status, updated_at, archived_at)
    ON public.care_guides TO authenticated;

GRANT SELECT ON public.animals_client, public.animal_updates_client,
    public.care_guides_client TO anon, authenticated;
GRANT SELECT ON public.listing_flags_client, public.user_roles_client,
    public.pilot_settings_client TO authenticated;

GRANT ALL PRIVILEGES ON TABLE public.user_roles, public.pilot_settings, public.animals, public.animal_updates,
    public.listing_flags, public.care_guides TO service_role;

REVOKE ALL ON SEQUENCE public.user_roles_id_seq, public.pilot_settings_id_seq, public.animals_id_seq,
    public.animal_updates_id_seq, public.listing_flags_id_seq, public.care_guides_id_seq
    FROM PUBLIC, anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.user_roles_id_seq, public.pilot_settings_id_seq, public.animals_id_seq,
    public.animal_updates_id_seq, public.listing_flags_id_seq, public.care_guides_id_seq
    TO service_role;

REVOKE ALL ON FUNCTION public.current_app_role() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.has_app_role(text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_app_role() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_app_role(text[]) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_app_role(text[]) TO service_role;

COMMIT;
