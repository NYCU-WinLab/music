import type { Action } from "@/lib/actions/define"
import {
  addPlaylist,
  addSong,
  listActivity,
  listPlayed,
  listQueue,
  nowPlaying,
  playNext,
  removeSong,
  searchMusic,
  setPaused,
  setVolume,
  skipSong,
  wantToo,
} from "@/lib/actions/music"
import { whoami } from "@/lib/actions/users"

/** Every action, in the order MCP lists them. */
export const actions: Action[] = [
  whoami,
  nowPlaying,
  listQueue,
  listActivity,
  listPlayed,
  searchMusic,
  addSong,
  addPlaylist,
  wantToo,
  playNext,
  skipSong,
  removeSong,
  setPaused,
  setVolume,
]
