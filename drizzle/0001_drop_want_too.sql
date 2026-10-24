DROP TABLE "queue_requests" CASCADE;--> statement-breakpoint
DELETE FROM "activities" WHERE "kind" = 'also';
