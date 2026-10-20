CREATE TABLE `admin_audit_logs` (
	`id` text PRIMARY KEY NOT NULL,
	`actor_id` text NOT NULL,
	`action` text NOT NULL,
	`target` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`actor_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `admin_audit_logs_actor_id_idx` ON `admin_audit_logs` (`actor_id`);--> statement-breakpoint
CREATE TABLE `after_sales` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`order_id` text NOT NULL,
	`subject` text NOT NULL,
	`status` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `after_sales_user_id_idx` ON `after_sales` (`user_id`);--> statement-breakpoint
CREATE INDEX `after_sales_order_id_idx` ON `after_sales` (`order_id`);--> statement-breakpoint
CREATE TABLE `after_sales_messages` (
	`id` text PRIMARY KEY NOT NULL,
	`ticket_id` text NOT NULL,
	`user_id` text NOT NULL,
	`body` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`ticket_id`) REFERENCES `after_sales`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `after_sales_messages_ticket_id_idx` ON `after_sales_messages` (`ticket_id`);--> statement-breakpoint
CREATE INDEX `after_sales_messages_user_id_idx` ON `after_sales_messages` (`user_id`);--> statement-breakpoint
CREATE TABLE `agents` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`parent_id` text,
	`code` text NOT NULL,
	`status` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `agents_user_id_unique` ON `agents` (`user_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `agents_code_unique` ON `agents` (`code`);--> statement-breakpoint
CREATE INDEX `agents_user_id_idx` ON `agents` (`user_id`);--> statement-breakpoint
CREATE TABLE `commissions` (
	`id` text PRIMARY KEY NOT NULL,
	`agent_id` text NOT NULL,
	`order_id` text NOT NULL,
	`amount` integer NOT NULL,
	`status` text NOT NULL,
	FOREIGN KEY (`agent_id`) REFERENCES `agents`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `commissions_order_id_unique` ON `commissions` (`order_id`);--> statement-breakpoint
CREATE INDEX `commissions_agent_id_idx` ON `commissions` (`agent_id`);--> statement-breakpoint
CREATE INDEX `commissions_order_id_idx` ON `commissions` (`order_id`);--> statement-breakpoint
CREATE TABLE `import_tasks` (
	`id` text PRIMARY KEY NOT NULL,
	`batch_id` text NOT NULL,
	`actor_id` text NOT NULL,
	`accepted` integer NOT NULL,
	`rejected` integer NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`batch_id`) REFERENCES `license_batches`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`actor_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `import_tasks_batch_id_idx` ON `import_tasks` (`batch_id`);--> statement-breakpoint
CREATE INDEX `import_tasks_actor_id_idx` ON `import_tasks` (`actor_id`);--> statement-breakpoint
CREATE TABLE `license_batches` (
	`id` text PRIMARY KEY NOT NULL,
	`product_id` text NOT NULL,
	`created_at` text NOT NULL,
	`count` integer NOT NULL,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `license_batches_product_id_idx` ON `license_batches` (`product_id`);--> statement-breakpoint
CREATE TABLE `licenses` (
	`id` text PRIMARY KEY NOT NULL,
	`batch_id` text NOT NULL,
	`product_id` text NOT NULL,
	`ciphertext` text NOT NULL,
	`fingerprint` text NOT NULL,
	`state` text NOT NULL,
	`order_id` text,
	FOREIGN KEY (`batch_id`) REFERENCES `license_batches`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `licenses_fingerprint_unique` ON `licenses` (`fingerprint`);--> statement-breakpoint
CREATE UNIQUE INDEX `licenses_order_id_unique` ON `licenses` (`order_id`);--> statement-breakpoint
CREATE INDEX `licenses_batch_id_idx` ON `licenses` (`batch_id`);--> statement-breakpoint
CREATE INDEX `licenses_product_id_idx` ON `licenses` (`product_id`);--> statement-breakpoint
CREATE INDEX `licenses_order_id_idx` ON `licenses` (`order_id`);--> statement-breakpoint
CREATE TABLE `notifications` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`body` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `notifications_user_id_idx` ON `notifications` (`user_id`);--> statement-breakpoint
CREATE TABLE `order_items` (
	`id` text PRIMARY KEY NOT NULL,
	`order_id` text NOT NULL,
	`product_id` text NOT NULL,
	`amount` integer NOT NULL,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `order_items_order_id_idx` ON `order_items` (`order_id`);--> statement-breakpoint
CREATE INDEX `order_items_product_id_idx` ON `order_items` (`product_id`);--> statement-breakpoint
CREATE TABLE `orders` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`product_id` text NOT NULL,
	`amount` integer NOT NULL,
	`status` text NOT NULL,
	`idempotency_key` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `orders_idempotency_key_unique` ON `orders` (`idempotency_key`);--> statement-breakpoint
CREATE INDEX `orders_user_id_idx` ON `orders` (`user_id`);--> statement-breakpoint
CREATE INDEX `orders_product_id_idx` ON `orders` (`product_id`);--> statement-breakpoint
CREATE TABLE `payments` (
	`id` text PRIMARY KEY NOT NULL,
	`order_id` text NOT NULL,
	`provider` text NOT NULL,
	`event_id` text NOT NULL,
	`amount` integer NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `payments_order_id_unique` ON `payments` (`order_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `payments_event_id_unique` ON `payments` (`event_id`);--> statement-breakpoint
CREATE INDEX `payments_order_id_idx` ON `payments` (`order_id`);--> statement-breakpoint
CREATE TABLE `permissions` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `permissions_name_unique` ON `permissions` (`name`);--> statement-breakpoint
CREATE TABLE `product_variants` (
	`id` text PRIMARY KEY NOT NULL,
	`product_id` text NOT NULL,
	`name` text NOT NULL,
	`price` integer NOT NULL,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `product_variants_product_id_idx` ON `product_variants` (`product_id`);--> statement-breakpoint
CREATE TABLE `products` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`description` text NOT NULL,
	`category` text NOT NULL,
	`kind` text NOT NULL,
	`icon` text NOT NULL,
	`price` integer NOT NULL,
	`original_price` integer NOT NULL,
	`agent_price` integer NOT NULL,
	`state` text NOT NULL,
	`reservable` integer NOT NULL,
	`source` text,
	`supplier` text,
	`evidence` text,
	`sales_basis` text,
	`reviewer` text,
	`reviewed_at` text,
	`review_note` text
);
--> statement-breakpoint
CREATE TABLE `roles` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `roles_name_unique` ON `roles` (`name`);--> statement-breakpoint
CREATE TABLE `service_orders` (
	`id` text PRIMARY KEY NOT NULL,
	`order_id` text NOT NULL,
	`user_id` text NOT NULL,
	`technician_id` text,
	`status` text NOT NULL,
	`device` text,
	`os` text,
	`software` text,
	`appointment` text,
	`contact` text,
	`description` text,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`technician_id`) REFERENCES `technicians`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `service_orders_order_id_unique` ON `service_orders` (`order_id`);--> statement-breakpoint
CREATE INDEX `service_orders_order_id_idx` ON `service_orders` (`order_id`);--> statement-breakpoint
CREATE INDEX `service_orders_user_id_idx` ON `service_orders` (`user_id`);--> statement-breakpoint
CREATE INDEX `service_orders_technician_id_idx` ON `service_orders` (`technician_id`);--> statement-breakpoint
CREATE TABLE `service_status_logs` (
	`id` text PRIMARY KEY NOT NULL,
	`service_id` text NOT NULL,
	`status` text NOT NULL,
	`note` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`service_id`) REFERENCES `service_orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `service_status_logs_service_id_idx` ON `service_status_logs` (`service_id`);--> statement-breakpoint
CREATE TABLE `settings` (
	`id` text PRIMARY KEY NOT NULL,
	`value` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `technicians` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`name` text NOT NULL,
	`contact` text NOT NULL,
	`wechat` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `technicians_user_id_unique` ON `technicians` (`user_id`);--> statement-breakpoint
CREATE INDEX `technicians_user_id_idx` ON `technicians` (`user_id`);--> statement-breakpoint
CREATE TABLE `user_roles` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`role` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `user_roles_user_id_idx` ON `user_roles` (`user_id`);--> statement-breakpoint
CREATE TABLE `user_wallets` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `user_wallets_user_id_unique` ON `user_wallets` (`user_id`);--> statement-breakpoint
CREATE INDEX `user_wallets_user_id_idx` ON `user_wallets` (`user_id`);--> statement-breakpoint
CREATE TABLE `users` (
	`id` text PRIMARY KEY NOT NULL,
	`email` text NOT NULL,
	`name` text NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `users_email_unique` ON `users` (`email`);--> statement-breakpoint
CREATE TABLE `wallet_transactions` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`amount` integer NOT NULL,
	`type` text NOT NULL,
	`reference` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `wallet_transactions_reference_unique` ON `wallet_transactions` (`reference`);--> statement-breakpoint
CREATE INDEX `wallet_transactions_user_id_idx` ON `wallet_transactions` (`user_id`);--> statement-breakpoint
CREATE TABLE `withdrawals` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`amount` integer NOT NULL,
	`status` text NOT NULL,
	`method` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `withdrawals_user_id_idx` ON `withdrawals` (`user_id`);