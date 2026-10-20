CREATE TABLE `supplier_products` (
	`id` text PRIMARY KEY NOT NULL,
	`provider` text NOT NULL,
	`upstream_id` text NOT NULL,
	`product_id` text NOT NULL,
	`upstream_name` text NOT NULL,
	`upstream_category` text NOT NULL,
	`upstream_price` integer NOT NULL,
	`cover_url` text,
	`stock_label` text NOT NULL,
	`stock_quantity` integer,
	`upstream_status` integer NOT NULL,
	`distribution` integer NOT NULL,
	`catalog_only` integer DEFAULT 1 NOT NULL,
	`seen_at` text NOT NULL,
	`source_url` text NOT NULL,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `supplier_products_product_id_unique` ON `supplier_products` (`product_id`);--> statement-breakpoint
CREATE INDEX `supplier_provider_idx` ON `supplier_products` (`provider`);--> statement-breakpoint
CREATE TABLE `supplier_sync_runs` (
	`id` text PRIMARY KEY NOT NULL,
	`provider` text NOT NULL,
	`actor_id` text NOT NULL,
	`status` text NOT NULL,
	`created_count` integer NOT NULL,
	`updated_count` integer NOT NULL,
	`skipped_count` integer NOT NULL,
	`message` text NOT NULL,
	`started_at` text NOT NULL,
	`completed_at` text,
	FOREIGN KEY (`actor_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
