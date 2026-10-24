import { MusicShell } from "@/components/music-shell"
import { runAction } from "@/lib/actions/define"
import { listActivity, listQueue, nowPlaying } from "@/lib/actions/music"
import { requireActor } from "@/lib/auth/session"

import { Activity } from "./activity"
import { AddSongs } from "./add-songs"
import { NowPlaying } from "./now-playing"
import { Queue } from "./queue"

export const dynamic = "force-dynamic"

export default async function Home() {
  const actor = await requireActor("/")
  const [playing, queue, activity] = await Promise.all([
    runAction(nowPlaying, actor, {}),
    runAction(listQueue, actor, {}),
    runAction(listActivity, actor, { limit: 20 }),
  ])
  return (
    <MusicShell>
      <div className="flex flex-col gap-12">
        <NowPlaying playing={playing} me={actor.userId} />
        <AddSongs />
        <Queue items={queue.items} me={actor.userId} />
        <Activity activities={activity.activities} />
      </div>
    </MusicShell>
  )
}
