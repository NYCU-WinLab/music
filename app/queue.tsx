"use client"

import { EllipsisIcon, HeartIcon } from "lucide-react"

import { EmptyState } from "@/components/empty-state"
import { SectionHeader } from "@/components/page-header"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import type { listQueue } from "@/lib/actions/music"

import { add, alsoWant, next, remove } from "./actions"
import { ok } from "./ok"
import { addedAsLabel, Cover, duration, people } from "./song"

type Item = Awaited<ReturnType<typeof listQueue.run>>["items"][number]

// What plays next, in order, with who asked for each song.
export function Queue({ items, me }: { items: Item[]; me: string }) {
  return (
    <section aria-label="接下來" className="flex flex-col gap-4">
      <SectionHeader title={`接下來 ${items.length ? items.length : ""}`} />
      {items.length ? (
        <ol className="flex flex-col">
          {items.map((item) => (
            <Row key={item.id} item={item} me={me} />
          ))}
        </ol>
      ) : (
        <EmptyState noun="排隊的歌" />
      )}
    </section>
  )
}

function Row({ item, me }: { item: Item; me: string }) {
  const wanted = item.requesters.some((r) => r.userId === me)
  const others = item.requesters
    .filter((r) => r.name !== item.addedBy)
    .map((r) => r.name)
  return (
    <li className="flex items-center gap-4 border-b border-border py-3">
      <Cover src={item.track.thumbnail} className="size-12" />
      <div className="flex min-w-0 flex-1 flex-col">
        <span className="truncate">{item.track.title}</span>
        <span className="truncate text-muted-foreground">
          {[item.track.artist, duration(item.track.durationS)]
            .filter(Boolean)
            .join("，")}
        </span>
        <span className="flex flex-wrap items-center gap-2 text-muted-foreground">
          {item.addedAs !== "queue" && (
            <Badge variant="muted">{addedAsLabel[item.addedAs]}</Badge>
          )}
          <span>
            {item.addedBy ?? "有人"}
            {item.fromPlaylist ? "的歌單" : addedAsLabel.queue}
            {others.length > 0 && `，${people(others)} 也想聽`}
          </span>
        </span>
      </div>
      <div className="flex shrink-0 gap-1">
        <Tooltip>
          <TooltipTrigger
            render={
              <Button
                variant={wanted ? "ghost" : "outline"}
                size="icon"
                aria-label={wanted ? "你想聽" : "我也想聽"}
                disabled={wanted}
                onClick={async () => ok(await alsoWant({ itemId: item.id }))}
              />
            }
          >
            <HeartIcon className={wanted ? "fill-current" : undefined} />
          </TooltipTrigger>
          <TooltipContent>
            {wanted ? "你想聽" : `我也想聽（${item.requesters.length}）`}
          </TooltipContent>
        </Tooltip>
        <DropdownMenu>
          <DropdownMenuTrigger
            render={<Button variant="ghost" size="icon" aria-label="更多" />}
          >
            <EllipsisIcon />
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem
              onClick={async () => ok(await next({ itemId: item.id }))}
            >
              下一首播
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={async () =>
                ok(await add({ videoId: item.track.videoId, as: "cut_in" }))
              }
            >
              插播
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={async () => ok(await remove({ itemId: item.id }))}
            >
              移出佇列
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </li>
  )
}
