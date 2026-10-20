CREATE INDEX orders_status_created_idx ON orders(status,created_at);
--> statement-breakpoint
CREATE INDEX products_state_category_idx ON products(state,category);
--> statement-breakpoint
CREATE INDEX licenses_stock_idx ON licenses(product_id,state);
--> statement-breakpoint
CREATE TRIGGER wallet_no_update BEFORE UPDATE ON wallet_transactions BEGIN SELECT RAISE(ABORT,'wallet ledger is append only'); END;
--> statement-breakpoint
CREATE TRIGGER wallet_no_delete BEFORE DELETE ON wallet_transactions BEGIN SELECT RAISE(ABORT,'wallet ledger is append only'); END;
--> statement-breakpoint
CREATE TRIGGER audit_no_update BEFORE UPDATE ON admin_audit_logs BEGIN SELECT RAISE(ABORT,'audit log is append only'); END;
--> statement-breakpoint
CREATE TRIGGER audit_no_delete BEFORE DELETE ON admin_audit_logs BEGIN SELECT RAISE(ABORT,'audit log is append only'); END;
--> statement-breakpoint
CREATE TRIGGER license_state_insert BEFORE INSERT ON licenses WHEN NEW.state NOT IN ('AVAILABLE','RESERVED','SOLD','USED','EXPIRED','INVALID') BEGIN SELECT RAISE(ABORT,'invalid license state'); END;
--> statement-breakpoint
CREATE TRIGGER license_state_update BEFORE UPDATE ON licenses WHEN NEW.state NOT IN ('AVAILABLE','RESERVED','SOLD','USED','EXPIRED','INVALID') OR (OLD.state IN ('SOLD','USED','EXPIRED','INVALID') AND NEW.state IN ('AVAILABLE','RESERVED')) BEGIN SELECT RAISE(ABORT,'invalid license transition'); END;
--> statement-breakpoint
CREATE TRIGGER product_state_insert BEFORE INSERT ON products WHEN NEW.state NOT IN ('DRAFT','PENDING_REVIEW','APPROVED','REJECTED','OFFLINE') OR NEW.price<=0 OR NEW.agent_price<=0 BEGIN SELECT RAISE(ABORT,'invalid product'); END;
--> statement-breakpoint
CREATE TRIGGER product_state_update BEFORE UPDATE ON products WHEN NEW.state NOT IN ('DRAFT','PENDING_REVIEW','APPROVED','REJECTED','OFFLINE') OR NEW.price<=0 OR NEW.agent_price<=0 OR (NEW.state='APPROVED' AND (COALESCE(NEW.source,'')='' OR COALESCE(NEW.supplier,'')='' OR COALESCE(NEW.evidence,'')='' OR COALESCE(NEW.sales_basis,'')='')) BEGIN SELECT RAISE(ABORT,'invalid product or missing review evidence'); END;
--> statement-breakpoint
CREATE TRIGGER order_state_insert BEFORE INSERT ON orders WHEN NEW.status NOT IN ('PENDING','PAID','BOOKED','COMPLETED','CANCELLED','REFUNDED') OR NEW.amount<=0 BEGIN SELECT RAISE(ABORT,'invalid order'); END;
--> statement-breakpoint
CREATE TRIGGER order_state_update BEFORE UPDATE ON orders WHEN NEW.status<>OLD.status AND NOT ((OLD.status='PENDING' AND NEW.status IN ('PAID','BOOKED','COMPLETED','CANCELLED')) OR (OLD.status IN ('PAID','BOOKED') AND NEW.status IN ('COMPLETED','REFUNDED')) OR (OLD.status='COMPLETED' AND NEW.status='REFUNDED')) BEGIN SELECT RAISE(ABORT,'invalid order transition'); END;
