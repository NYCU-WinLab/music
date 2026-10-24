import { cn } from "@/lib/utils"

/** m:ss */
export function duration(seconds: number | null | undefined) {
  if (seconds === null || seconds === undefined) return ""
  const s = Math.max(0, Math.floor(seconds))
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`
}

/** The cover art, square, from YouTube. */
export function Cover({
  src,
  className,
}: {
  src: string | null
  className?: string
}) {
  return src ? (
    // eslint-disable-next-line @next/next/no-img-element -- remote YouTube art at its own size
    <img
      src={src}
      alt=""
      loading="lazy"
      referrerPolicy="no-referrer"
      className={cn(
        "shrink-0 rounded-control bg-muted object-cover",
        className
      )}
    />
  ) : (
    <div className={cn("shrink-0 rounded-control bg-muted", className)} />
  )
}

/** "小明" / "小明、小華" / "小明、小華 等 5 人" */
export function people(names: string[]) {
  if (names.length <= 3) return names.join("、")
  return `${names.slice(0, 3).join("、")} 等 ${names.length} 人`
}

export const addedAsLabel = {
  queue: "點播",
  next: "排下一首",
  cut_in: "插播",
} as const
