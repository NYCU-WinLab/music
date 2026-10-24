CREATE TABLE "accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"account_id" text NOT NULL,
	"provider_id" text NOT NULL,
	"user_id" uuid NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"id_token" text,
	"access_token_expires_at" timestamp with time zone,
	"refresh_token_expires_at" timestamp with time zone,
	"scope" text,
	"password" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone NOT NULL
);
--> statement-breakpoint
CREATE TABLE "jwks" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"public_key" text NOT NULL,
	"private_key" text NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	"expires_at" timestamp with time zone,
	"alg" text,
	"crv" text
);
--> statement-breakpoint
CREATE TABLE "oauth_access_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"token" text NOT NULL,
	"client_id" text NOT NULL,
	"session_id" uuid,
	"user_id" uuid,
	"reference_id" text,
	"authorization_code_id" text,
	"resources" jsonb,
	"requested_user_info_claims" jsonb,
	"refresh_id" uuid,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	"revoked" timestamp with time zone,
	"confirmation" jsonb,
	"scopes" jsonb NOT NULL,
	CONSTRAINT "oauth_access_tokens_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "oauth_clients" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"client_id" text NOT NULL,
	"client_secret" text,
	"client_discovery_id" text,
	"disabled" boolean,
	"skip_consent" boolean,
	"enable_end_session" boolean,
	"subject_type" text,
	"scopes" jsonb,
	"client_credentials_scopes" jsonb,
	"user_id" uuid,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"name" text,
	"uri" text,
	"icon" text,
	"contacts" jsonb,
	"tos" text,
	"policy" text,
	"software_id" text,
	"software_version" text,
	"software_statement" text,
	"redirect_uris" jsonb NOT NULL,
	"post_logout_redirect_uris" jsonb,
	"backchannel_logout_uri" text,
	"backchannel_logout_session_required" boolean,
	"token_endpoint_auth_method" text,
	"application_type" text,
	"jwks" text,
	"jwks_uri" text,
	"grant_types" jsonb,
	"response_types" jsonb,
	"require_pkce" boolean,
	"dpop_bound_access_tokens" boolean,
	"reference_id" text,
	"metadata" jsonb,
	CONSTRAINT "oauth_clients_clientId_unique" UNIQUE("client_id")
);
--> statement-breakpoint
CREATE TABLE "oauth_client_assertions" (
	"id" text PRIMARY KEY NOT NULL,
	"expires_at" timestamp with time zone NOT NULL
);
--> statement-breakpoint
CREATE TABLE "oauth_client_resources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"client_id" text NOT NULL,
	"resource_id" text NOT NULL,
	"metadata" jsonb,
	"created_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "oauth_consents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"client_id" text NOT NULL,
	"user_id" uuid,
	"reference_id" text,
	"resources" jsonb,
	"requested_user_info_claims" jsonb,
	"scopes" jsonb NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	"updated_at" timestamp with time zone NOT NULL
);
--> statement-breakpoint
CREATE TABLE "oauth_refresh_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"token" text NOT NULL,
	"client_id" text NOT NULL,
	"session_id" uuid,
	"user_id" uuid NOT NULL,
	"reference_id" text,
	"authorization_code_id" text,
	"resources" jsonb,
	"requested_user_info_claims" jsonb,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	"revoked" timestamp with time zone,
	"rotated_at" timestamp with time zone,
	"rotation_replay_response" text,
	"rotation_replay_expires_at" timestamp with time zone,
	"auth_time" timestamp with time zone,
	"confirmation" jsonb,
	"scopes" jsonb NOT NULL,
	CONSTRAINT "oauth_refresh_tokens_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "oauth_resources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"identifier" text NOT NULL,
	"name" text NOT NULL,
	"access_token_ttl" integer,
	"refresh_token_ttl" integer,
	"signing_algorithm" text,
	"signing_key_id" text,
	"allowed_scopes" jsonb,
	"custom_claims" jsonb,
	"dpop_bound_access_tokens_required" boolean,
	"disabled" boolean,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"policy_version" integer,
	"metadata" jsonb,
	CONSTRAINT "oauth_resources_identifier_unique" UNIQUE("identifier")
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"token" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"user_id" uuid NOT NULL,
	CONSTRAINT "sessions_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean NOT NULL,
	"image" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"username" text,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "verifications" (
	"id" text PRIMARY KEY NOT NULL,
	"identifier" text NOT NULL,
	"value" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "activities" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"kind" text NOT NULL,
	"item_id" uuid,
	"detail" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "player" (
	"id" integer PRIMARY KEY DEFAULT 1 NOT NULL,
	"paused" boolean DEFAULT false NOT NULL,
	"volume" real DEFAULT 40 NOT NULL,
	"version" integer DEFAULT 0 NOT NULL,
	"position_s" real DEFAULT 0 NOT NULL,
	"position_at" timestamp with time zone,
	"state" text DEFAULT 'idle' NOT NULL,
	"error" text,
	"seen_at" timestamp with time zone,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "queue_items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"video_id" text NOT NULL,
	"status" text DEFAULT 'queued' NOT NULL,
	"sort" double precision NOT NULL,
	"added_by" uuid,
	"added_as" text DEFAULT 'queue' NOT NULL,
	"playlist_id" text,
	"resume_at_s" real DEFAULT 0 NOT NULL,
	"started_at" timestamp with time zone,
	"ended_at" timestamp with time zone,
	"ended_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "queue_requests" (
	"item_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "queue_requests_item_id_user_id_pk" PRIMARY KEY("item_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "tracks" (
	"video_id" text PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"artist" text DEFAULT '' NOT NULL,
	"duration_s" integer,
	"thumbnail" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD CONSTRAINT "oauth_access_tokens_client_id_oauth_clients_client_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."oauth_clients"("client_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD CONSTRAINT "oauth_access_tokens_session_id_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."sessions"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD CONSTRAINT "oauth_access_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD CONSTRAINT "oauth_access_tokens_refresh_id_oauth_refresh_tokens_id_fk" FOREIGN KEY ("refresh_id") REFERENCES "public"."oauth_refresh_tokens"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_clients" ADD CONSTRAINT "oauth_clients_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_client_resources" ADD CONSTRAINT "oauth_client_resources_client_id_oauth_clients_client_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."oauth_clients"("client_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_client_resources" ADD CONSTRAINT "oauth_client_resources_resource_id_oauth_resources_identifier_fk" FOREIGN KEY ("resource_id") REFERENCES "public"."oauth_resources"("identifier") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_consents" ADD CONSTRAINT "oauth_consents_client_id_oauth_clients_client_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."oauth_clients"("client_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_consents" ADD CONSTRAINT "oauth_consents_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_refresh_tokens" ADD CONSTRAINT "oauth_refresh_tokens_client_id_oauth_clients_client_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."oauth_clients"("client_id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_refresh_tokens" ADD CONSTRAINT "oauth_refresh_tokens_session_id_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."sessions"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "oauth_refresh_tokens" ADD CONSTRAINT "oauth_refresh_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activities" ADD CONSTRAINT "activities_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activities" ADD CONSTRAINT "activities_item_id_queue_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."queue_items"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "queue_items" ADD CONSTRAINT "queue_items_video_id_tracks_video_id_fk" FOREIGN KEY ("video_id") REFERENCES "public"."tracks"("video_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "queue_items" ADD CONSTRAINT "queue_items_added_by_users_id_fk" FOREIGN KEY ("added_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "queue_items" ADD CONSTRAINT "queue_items_ended_by_users_id_fk" FOREIGN KEY ("ended_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "queue_requests" ADD CONSTRAINT "queue_requests_item_id_queue_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."queue_items"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "queue_requests" ADD CONSTRAINT "queue_requests_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "accounts_user_id_index" ON "accounts" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "oauth_access_tokens_authorization_code_id_index" ON "oauth_access_tokens" USING btree ("authorization_code_id");--> statement-breakpoint
CREATE INDEX "oauth_access_tokens_client_id_index" ON "oauth_access_tokens" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "oauth_access_tokens_refresh_id_index" ON "oauth_access_tokens" USING btree ("refresh_id");--> statement-breakpoint
CREATE INDEX "oauth_access_tokens_session_id_index" ON "oauth_access_tokens" USING btree ("session_id");--> statement-breakpoint
CREATE INDEX "oauth_access_tokens_user_id_index" ON "oauth_access_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "oauth_clients_user_id_index" ON "oauth_clients" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "oauth_client_resources_client_id_index" ON "oauth_client_resources" USING btree ("client_id");--> statement-breakpoint
CREATE UNIQUE INDEX "oauth_client_resources_client_id_resource_id_index" ON "oauth_client_resources" USING btree ("client_id","resource_id");--> statement-breakpoint
CREATE INDEX "oauth_client_resources_resource_id_index" ON "oauth_client_resources" USING btree ("resource_id");--> statement-breakpoint
CREATE INDEX "oauth_consents_client_id_index" ON "oauth_consents" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "oauth_consents_user_id_index" ON "oauth_consents" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "oauth_refresh_tokens_authorization_code_id_index" ON "oauth_refresh_tokens" USING btree ("authorization_code_id");--> statement-breakpoint
CREATE INDEX "oauth_refresh_tokens_client_id_index" ON "oauth_refresh_tokens" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "oauth_refresh_tokens_session_id_index" ON "oauth_refresh_tokens" USING btree ("session_id");--> statement-breakpoint
CREATE INDEX "oauth_refresh_tokens_user_id_index" ON "oauth_refresh_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "sessions_user_id_index" ON "sessions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "verifications_identifier_index" ON "verifications" USING btree ("identifier");--> statement-breakpoint
CREATE INDEX "activities_created" ON "activities" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "queue_items_status_sort" ON "queue_items" USING btree ("status","sort");--> statement-breakpoint
CREATE INDEX "queue_items_ended" ON "queue_items" USING btree ("ended_at");INSERT INTO "player" ("id") VALUES (1) ON CONFLICT DO NOTHING;
