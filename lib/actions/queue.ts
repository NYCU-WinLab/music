// The queue's shared steps, used by member actions (music.ts) and by the
// player (player.ts). Every write runs in withQueue: one transaction that
// holds the player row, so two members pressing at once take turns.
import { and, asc, desc, eq, inArray, sql } from "drizzle-orm"

import { fillQueue } from "@/lib/actions/autoplay"
import { db } from "@/lib/db"
import { activities, player, queueItems, tracks, user } from "@/lib/db/schema"
import type { Track } from "@/lib/youtube"

export type Tx = Parameters<Parameters<typeof db.transaction>[0]>[0]

/** Runs fn holding the one player row; afterwards the queue has a current
 * item whenever it has any item, and the player's version moves on. A queue
 * left with nothing waiting gets a recommendation after the commit. */
export async function withQueue<T>(fn: (tx: Tx) => Promise<T>): Promise<T> {
  const result = await inQueue(fn)
  setTimeout(() => void fillQueue(), 0)
  return result
}

/** withQueue without the recommendation, for autoplay itself. */
export async function inQueue<T>(fn: (tx: Tx) => Promise<T>): Promise<T> {
  return db.transaction(async (tx) => {
    await tx.insert(player).values({ id: 1 }).onConflictDoNothing()
    await tx.execute(sql`select 1 from ${player} where id = 1 for update`)
    const result = await fn(tx)
    await promote(tx)
    await tx
      .update(player)
      .set({ version: sql`${player.version} + 1`, updatedAt: new Date() })
      .where(eq(player.id, 1))
    return result
  })
}

/** Takes waiting recommendations out: a member's song goes first, and
 * autoplay recommends again once the queue is dry. */
export async function dropRecommendations(tx: Tx) {
  await tx
    .update(queueItems)
    .set({ status: "removed", endedAt: new Date() })
    .where(and(eq(queueItems.status, "queued"), eq(queueItems.addedAs, "auto")))
}

/** The playing item, if any. */
export async function currentItem(tx: Tx) {
  const [item] = await tx
    .select()
    .from(queueItems)
    .where(eq(queueItems.status, "playing"))
    .limit(1)
  return item ?? null
}

// With nothing playing, the first queued item starts.
async function promote(tx: Tx) {
  if (await currentItem(tx)) return
  const [next] = await tx
    .select({ id: queueItems.id })
    .from(queueItems)
    .where(eq(queueItems.status, "queued"))
    .orderBy(asc(queueItems.sort))
    .limit(1)
  if (!next) return
  await tx
    .update(queueItems)
    .set({ status: "playing", startedAt: new Date() })
    .where(eq(queueItems.id, next.id))
  await tx
    .update(player)
    .set({ positionS: 0, positionAt: null, state: "loading", error: null })
    .where(eq(player.id, 1))
}

/** Where the playing song is now, in seconds, from the player's last
 * report and the time since. */
export function positionNow(state: typeof player.$inferSelect) {
  const running =
    state.state === "playing" && !state.paused && state.positionAt !== null
  return (
    state.positionS +
    (running ? (Date.now() - state.positionAt!.getTime()) / 1000 : 0)
  )
}

export async function playerRow(tx: Tx | typeof db = db) {
  const [row] = await tx.select().from(player).where(eq(player.id, 1))
  return row ?? null
}

/** Sort keys for the end and the front of the queue. */
export async function sortKeys(tx: Tx) {
  const [row] = await tx
    .select({
      min: sql<number | null>`min(${queueItems.sort})`,
      max: sql<number | null>`max(${queueItems.sort})`,
    })
    .from(queueItems)
    .where(eq(queueItems.status, "queued"))
  return {
    end: (row?.max ?? 0) + 1,
    front: (row?.min ?? 0) - 1,
  }
}

export async function saveTracks(tx: Tx, list: Track[]) {
  if (!list.length) return
  await tx
    .insert(tracks)
    .values(list)
    .onConflictDoUpdate({
      target: tracks.videoId,
      set: {
        title: sql`excluded.title`,
        artist: sql`excluded.artist`,
        durationS: sql`excluded.duration_s`,
        thumbnail: sql`excluded.thumbnail`,
      },
    })
}

/** The waiting or playing item of a video, if it is already in the queue. */
export async function liveItemOf(tx: Tx, videoId: string) {
  const [item] = await tx
    .select()
    .from(queueItems)
    .where(
      and(
        eq(queueItems.videoId, videoId),
        inArray(queueItems.status, ["queued", "playing"])
      )
    )
    .limit(1)
  return item ?? null
}

export async function logActivity(
  tx: Tx,
  entry: typeof activities.$inferInsert
) {
  await tx.insert(activities).values(entry)
}

/** Items with their song and who added, skipped or removed them. */
export async function describeItems(
  tx: Tx | typeof db,
  items: (typeof queueItems.$inferSelect)[]
) {
  if (!items.length) return []
  const [songs, people] = await Promise.all([
    tx
      .select()
      .from(tracks)
      .where(
        inArray(
          tracks.videoId,
          items.map((item) => item.videoId)
        )
      ),
    tx
      .select({ id: user.id, name: user.name })
      .from(user)
      .where(
        inArray(user.id, [
          ...new Set(
            items.flatMap((item) =>
              [item.addedBy, item.endedBy].filter((id): id is string => !!id)
            )
          ),
          "00000000-0000-0000-0000-000000000000",
        ])
      ),
  ])
  const song = new Map(songs.map((s) => [s.videoId, s]))
  const name = new Map(people.map((p) => [p.id, p.name]))
  return items.map((item) => ({
    id: item.id,
    status: item.status,
    addedAs: item.addedAs,
    fromPlaylist: item.playlistId !== null,
    track: song.get(item.videoId)!,
    addedBy: item.addedBy ? (name.get(item.addedBy) ?? null) : null,
    endedBy: item.endedBy ? (name.get(item.endedBy) ?? null) : null,
    startedAt: item.startedAt,
    endedAt: item.endedAt,
  }))
}

export async function queuedItems(tx: Tx | typeof db = db) {
  return tx
    .select()
    .from(queueItems)
    .where(eq(queueItems.status, "queued"))
    .orderBy(asc(queueItems.sort))
}

/** Volume changes by one member within this long before their last one read as
 * one: the level they settled on. */
const VOLUME_RUN_MS = 60_000

export async function recentActivities(limit: number) {
  const rows = await db
    .select({
      id: activities.id,
      kind: activities.kind,
      detail: activities.detail,
      createdAt: activities.createdAt,
      userId: activities.userId,
      who: user.name,
      title: tracks.title,
    })
    .from(activities)
    .leftJoin(user, eq(user.id, activities.userId))
    .leftJoin(queueItems, eq(queueItems.id, activities.itemId))
    .leftJoin(tracks, eq(tracks.videoId, queueItems.videoId))
    .orderBy(desc(activities.id))
    // Enough to fill the page after runs of volume clicks fold up.
    .limit(limit * 5)
  const out: typeof rows = []
  for (const row of rows) {
    const last = out.at(-1)
    const sameRun =
      last?.kind === "volume" &&
      row.kind === "volume" &&
      last.userId === row.userId &&
      last.createdAt.getTime() - row.createdAt.getTime() < VOLUME_RUN_MS
    if (!sameRun) out.push(row)
  }
  return out.slice(0, limit).map((row) => ({ ...row, userId: undefined }))
}
