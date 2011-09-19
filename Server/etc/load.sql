CREATE USER analytics WITH PASSWORD '---PASSWORD---';

CREATE TYPE "public"."platform" AS ENUM (
	'Mac',
	'iPhone',
	'iPad',
	'Android',
	'WebOS',
	'Windows',
	'Windows Phone'
);
ALTER TYPE "public"."platform" OWNER TO "analytics";

CREATE SEQUENCE "public"."event_ids" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."event_ids" OWNER TO "analytics";

CREATE TABLE "public"."events" (
	"timestamp" timestamp(6) NOT NULL,
	"platform_os_version" text,
	"event_id" int4 NOT NULL DEFAULT nextval('event_ids'::regclass),
	"platform_os" "public"."platform",
	"device_id" uuid,
	"event_name" text NOT NULL,
	"event_target" text NOT NULL,
	"duration" float4,
	CONSTRAINT "events_eventid_key" UNIQUE ("event_id") NOT DEFERRABLE INITIALLY IMMEDIATE
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."events" OWNER TO "analytics";
CREATE INDEX "timestamp" ON "public"."events" USING btree("timestamp" DESC NULLS LAST);