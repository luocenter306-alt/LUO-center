CREATE TABLE `auth_credentials` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`identifier` text NOT NULL,
	`kind` text NOT NULL,
	`password_hash` text NOT NULL,
	`salt` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `auth_credentials_user_id_unique` ON `auth_credentials` (`user_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `auth_credentials_identifier_unique` ON `auth_credentials` (`identifier`);--> statement-breakpoint
CREATE TABLE `auth_limits` (
	`id` text PRIMARY KEY NOT NULL,
	`attempts` integer NOT NULL,
	`reset_at` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `auth_sessions` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`expires_at` integer NOT NULL,
	`created_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `auth_sessions_user_idx` ON `auth_sessions` (`user_id`);--> statement-breakpoint
CREATE INDEX `auth_sessions_expiry_idx` ON `auth_sessions` (`expires_at`);