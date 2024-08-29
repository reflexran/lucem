## Roblox thumbnails API wrapper
## Copyright (C) 2024 Trayambak Rai

import std/[httpclient, strutils, logging]
import jsony
import ./games
import ../sugar

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
  let
    client = newHttpClient(userAgent = "curl/8.8.0")
    url = "https://thumbnails.roblox.com/v1/games/icons?universeIds=$1&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false" % [
      $id
    ]
    resp = client.get(url)
  
  info "getGameIcon($1): $2 ($3)" % [$id, resp.body, url]

  fromJson(resp.body, StubData[Thumbnail]).data[0].some()
