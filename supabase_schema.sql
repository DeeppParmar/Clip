CREATE TABLE account_deletions (
	id UUID NOT NULL, 
	former_user_id TEXT NOT NULL, 
	email_sha256 TEXT NOT NULL, 
	stripe_customer_id TEXT, 
	plan_at_deletion VARCHAR(20), 
	r2_objects_deleted INTEGER, 
	reason VARCHAR(32), 
	deleted_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id)
);

CREATE TABLE first_video_grants (
	id UUID NOT NULL, 
	ip_hash VARCHAR(64) NOT NULL, 
	job_id TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id)
);

CREATE TABLE magic_link_tokens (
	id UUID NOT NULL, 
	email CITEXT NOT NULL, 
	token_hash TEXT NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	used_at TIMESTAMP WITH TIME ZONE, 
	request_ip TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	UNIQUE (token_hash)
);

CREATE TABLE oauth_clients (
	id TEXT NOT NULL, 
	client_name TEXT NOT NULL, 
	redirect_uris TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id)
);

CREATE TABLE proxy_usage (
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	source VARCHAR(16) NOT NULL, 
	job_id VARCHAR(64), 
	url_host VARCHAR(120), 
	route VARCHAR(32), 
	paid_bytes INTEGER NOT NULL, 
	detail JSONB, 
	PRIMARY KEY (id)
);

CREATE TABLE stripe_events (
	id TEXT NOT NULL, 
	type TEXT, 
	created TIMESTAMP WITH TIME ZONE, 
	processed_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id)
);

CREATE TABLE users (
	id UUID NOT NULL, 
	email CITEXT NOT NULL, 
	google_sub TEXT, 
	stripe_customer_id TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	last_login_at TIMESTAMP WITH TIME ZONE, 
	marketing_opt_out BOOLEAN DEFAULT 'false' NOT NULL, 
	free_plan_denied VARCHAR(32), 
	ban_reason TEXT, 
	banned_at TIMESTAMP WITH TIME ZONE, 
	PRIMARY KEY (id), 
	UNIQUE (email), 
	UNIQUE (google_sub), 
	UNIQUE (stripe_customer_id)
);

CREATE TABLE api_keys (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	name TEXT NOT NULL, 
	key_hash TEXT NOT NULL, 
	prefix TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	last_used_at TIMESTAMP WITH TIME ZONE, 
	revoked_at TIMESTAMP WITH TIME ZONE, 
	scope TEXT, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (key_hash)
);

CREATE TABLE autopilot_runs (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	video_id TEXT NOT NULL, 
	video_url TEXT, 
	video_title TEXT, 
	thumbnail_url TEXT, 
	published_at TIMESTAMP WITH TIME ZONE, 
	trigger VARCHAR(12) NOT NULL, 
	status VARCHAR(16) NOT NULL, 
	reason TEXT, 
	job_id TEXT, 
	clips_count INTEGER, 
	posted_count INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	CONSTRAINT uq_autopilot_user_video UNIQUE (user_id, video_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE autopilot_settings (
	user_id UUID NOT NULL, 
	enabled BOOLEAN NOT NULL, 
	enabled_at TIMESTAMP WITH TIME ZONE, 
	rights_ack_at TIMESTAMP WITH TIME ZONE, 
	autopublish BOOLEAN NOT NULL, 
	publish_platforms JSONB, 
	clips_to_publish INTEGER NOT NULL, 
	max_minutes INTEGER NOT NULL, 
	publish_hour INTEGER NOT NULL, 
	timezone TEXT, 
	last_checked_at TIMESTAMP WITH TIME ZONE, 
	last_error TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE cancellation_feedback (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	stripe_subscription_id TEXT, 
	plan VARCHAR(20), 
	interval VARCHAR(10), 
	reason VARCHAR(32) NOT NULL, 
	details TEXT, 
	rating INTEGER, 
	review TEXT, 
	review_public_ok BOOLEAN NOT NULL, 
	outcome VARCHAR(16), 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE credit_topups (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	stripe_session_id TEXT, 
	minutes_total INTEGER NOT NULL, 
	minutes_consumed NUMERIC(10, 2) NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (stripe_session_id)
);

CREATE TABLE evidence_events (
	id UUID NOT NULL, 
	user_id UUID, 
	email CITEXT, 
	kind TEXT NOT NULL, 
	method TEXT NOT NULL, 
	ip TEXT, 
	user_agent TEXT, 
	meta JSONB DEFAULT '{}' NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE lifecycle_emails (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	kind VARCHAR(32) NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	CONSTRAINT uq_lifecycle_user_kind UNIQUE (user_id, kind), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE login_codes (
	code_hash TEXT NOT NULL, 
	user_id UUID NOT NULL, 
	challenge TEXT NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	used_at TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (code_hash), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE oauth_codes (
	code_hash TEXT NOT NULL, 
	client_id TEXT NOT NULL, 
	user_id UUID NOT NULL, 
	redirect_uri TEXT NOT NULL, 
	code_challenge TEXT NOT NULL, 
	scope TEXT, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	used_at TIMESTAMP WITH TIME ZONE, 
	PRIMARY KEY (code_hash), 
	FOREIGN KEY(client_id) REFERENCES oauth_clients (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE onboarding_surveys (
	user_id UUID NOT NULL, 
	skipped BOOLEAN NOT NULL, 
	source VARCHAR(32), 
	source_other TEXT, 
	goals JSONB, 
	role VARCHAR(32), 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE projects (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	job_id TEXT NOT NULL, 
	title TEXT, 
	metadata_r2_key TEXT NOT NULL, 
	state JSONB, 
	size_bytes INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (job_id)
);

CREATE TABLE signup_attribution (
	user_id UUID NOT NULL, 
	referrer TEXT, 
	referrer_host TEXT, 
	landing_path TEXT, 
	utm_source TEXT, 
	utm_medium TEXT, 
	utm_campaign TEXT, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE subscriptions (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	stripe_subscription_id TEXT NOT NULL, 
	stripe_price_id TEXT, 
	plan VARCHAR(20) NOT NULL, 
	interval VARCHAR(10) NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	minutes_per_period INTEGER NOT NULL, 
	current_period_start TIMESTAMP WITH TIME ZONE NOT NULL, 
	current_period_end TIMESTAMP WITH TIME ZONE NOT NULL, 
	cancel_at_period_end BOOLEAN NOT NULL, 
	hold_from TIMESTAMP WITH TIME ZONE, 
	hold_until TIMESTAMP WITH TIME ZONE, 
	last_event_at TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	UNIQUE (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (stripe_subscription_id)
);

CREATE TABLE upload_post_profiles (
	user_id UUID NOT NULL, 
	profile_username TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (profile_username)
);

CREATE TABLE usage_ledger (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	job_id TEXT NOT NULL, 
	job_type VARCHAR(20) NOT NULL, 
	minutes NUMERIC(10, 2) NOT NULL, 
	minutes_from_plan NUMERIC(10, 2) NOT NULL, 
	minutes_from_topup NUMERIC(10, 2) NOT NULL, 
	topup_allocations JSONB, 
	status VARCHAR(12) NOT NULL, 
	period_end TIMESTAMP WITH TIME ZONE, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE user_videos (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	job_id TEXT NOT NULL, 
	clip_index INTEGER, 
	r2_key TEXT NOT NULL, 
	title TEXT, 
	size_bytes INTEGER, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE clip_expiry_warnings (
	video_id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	warned_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	PRIMARY KEY (video_id), 
	FOREIGN KEY(video_id) REFERENCES user_videos (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE oauth_refresh_tokens (
	token_hash TEXT NOT NULL, 
	api_key_id UUID NOT NULL, 
	client_id TEXT NOT NULL, 
	user_id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), 
	last_used_at TIMESTAMP WITH TIME ZONE, 
	PRIMARY KEY (token_hash), 
	FOREIGN KEY(api_key_id) REFERENCES api_keys (id) ON DELETE CASCADE, 
	FOREIGN KEY(client_id) REFERENCES oauth_clients (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
)
