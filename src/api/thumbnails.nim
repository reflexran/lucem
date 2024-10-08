## Roblox thumbnails API wrapper
## Copyright (C) 2024 Trayambak Rai

import std/[strutils, logging]
import jsony
import ./games
import ../[cache_calls, sugar, http]

type
  ThumbnailState* {.pure.} = enum
    Error = "Error"
    Completed = "Completed"
    InReview = "InReview"
    Pending = "Pending"
    Blocked = "Blocked"
    TemporarilyUnavailable = "TemporarilyAvailable"

  ReturnPolicy* = enum
    Placeholder = "PlaceHolder"
    AutoGenerated = "AutoGenerated"
    ForceAutoGenerated = "ForceAutoGenerated"

  ThumbnailFormat* = enum
    Png = "png"
    Jpeg = "Jpeg"

  Thumbnail* = object
    targetId*: int64
    state*: ThumbnailState
    imageUrl*, version*: string

proc getGameIcon*(id: UniverseID): Option[Thumbnail] =
  if (
    let cached = findCacheSingleParam[Thumbnail]("roblox.getGameIcon", $id, 1)
    *cached
  ):
    debug "getGameIcon($1): cache hit!" % [$id]
    return cached

  let
    url =
      "https://thumbnails.roblox.com/v1/games/icons?universeIds=$1&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false" %
      [$id]
    resp = httpGet(url)

  debug "getGameIcon($1): $2 ($3)" % [$id, resp, url]

  let payload = fromJson(resp, StubData[Thumbnail]).data[0]
  cacheSingleParam[Thumbnail]("roblox.getGameIcon", $id, payload)

  payload.some()
