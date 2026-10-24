import { EmptyState } from "@/components/empty-state"
import { MusicShell } from "@/components/music-shell"
import { PageHeader } from "@/components/page-header"
import { runAction } from "@/lib/actions/define"
import { listPlayed } from "@/lib/actions/music"
import { requireActor } from "@/lib/auth/session"

import { AddButtons } from "../add-songs"
import { addedAsLabel, Cover } from "../song"

export const dynamic = "force-dynamic"

const time = new Intl.DateTimeFormat("zh-TW", {
  timeZone: "Asia/Taipei",
  month: "numeric",
  day: "numeric",
  hour: "2-digit",
  minute: "2-digit",
  hour12: false,
})

const ending = { done: "", skipped: "跳過", removed: "移出" } as const

export default async function Played() {
  const actor = await requireActor("/played")
  const { items } = await runAction(listPlayed, actor, { limit: 50 })
  return (
    <MusicShell page={{ label: "播過", href: "/played", tip: "" }}>
      <div className="flex flex-col gap-8">
        <PageHeader title="播過的歌" />
        {items.length ? (
          <ol className="flex flex-col">
            {items.map((item) => {
              const how =
                item.status === "done" ||
                item.status === "skipped" ||
                item.status === "removed"
                  ? ending[item.status]
                  : ""
              return (
                <li
                  key={item.id}
                  className="flex items-center gap-4 border-b border-border py-3"
                >
                  <Cover src={item.track.thumbnail} className="size-12" />
                  <div className="flex min-w-0 flex-1 flex-col">
                    <span className="truncate">{item.track.title}</span>
                    <span className="truncate text-muted-foreground">
                      {item.addedBy ?? "有人"}
                      {item.fromPlaylist
                        ? "的歌單"
                        : addedAsLabel[item.addedAs]}
                      {how && `，${item.endedBy ?? "播放器"}${how}`}
                    </span>
                  </div>
                  <span className="hidden shrink-0 text-muted-foreground tabular-nums sm:inline">
                    {item.endedAt ? time.format(item.endedAt) : ""}
                  </span>
                  <AddButtons videoId={item.track.videoId} />
                </li>
              )
            })}
          </ol>
        ) : (
          <EmptyState noun="播過的歌" />
        )}
      </div>
    </MusicShell>
  )
}
