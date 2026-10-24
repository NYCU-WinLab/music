import {
  AppShell,
  BuildVersion,
  CornerLink,
  CornerTip,
} from "@/components/app-shell"
import { LiveRefresh } from "@/components/live-refresh"
import { getSession } from "@/lib/auth/session"

// Music's corners: the lab and the page in the breadcrumb, the member's
// account next to the build in the bottom left.
export async function MusicShell({
  page,
  layout,
  children,
}: {
  page?: { label: string; href: string; tip: string }
  layout?: "column" | "spotlight" | "wide"
  children: React.ReactNode
}) {
  const session = await getSession()
  return (
    <AppShell
      layout={layout}
      breadcrumb={[
        { label: "WinLab", href: "https://portal.winlab.tw", tip: "" },
        { label: "Music", href: "/", tip: "" },
        ...(page ? [page] : []),
      ]}
      nav={[
        { label: "播放", href: "/", tip: "" },
        { label: "播過", href: "/played", tip: "" },
      ]}
      corners={{
        bottomLeft: (
          <>
            {session && (
              <CornerTip tip={session.user.email} corner="bottom-left">
                <CornerLink href="/profile" prefetch>
                  {session.user.name}
                </CornerLink>
              </CornerTip>
            )}
            <BuildVersion />
          </>
        ),
      }}
    >
      <LiveRefresh />
      {children}
    </AppShell>
  )
}
