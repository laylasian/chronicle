module Database where

import Json.Decode  as J
import Json.Decode exposing ((:=))
import Task         exposing (Task, ThreadID, andThen)
import Signal       exposing (Signal, Mailbox, mailbox, send)

import Http             exposing (Error, get)

import Util as U
import Model
import Controller

-- Using production table
tableName : String
tableName =
  "feelings"

allUrl : String
allUrl =
  "/" ++ tableName

feelingDecoder : J.Decoder Model.Feeling
feelingDecoder = Model.Feeling
  `J.map`    ("how"    := J.string)
  `U.andMap` ("what" := J.string)
  `U.andMap` ("trigger"  := J.string)
  `U.andMap` ("notes"   := J.string)
  `U.andMap` ("at"  := J.string)
  `U.andMap` ("day"  := J.string)

feelingsDecoder : J.Decoder Model.Model
feelingsDecoder = J.list feelingDecoder


-- XXX: must handle error case from `get` using Result x a
getFeelings : Task Error ()
getFeelings =
  get feelingsDecoder allUrl
    `andThen` \feelings ->
      send (.address Controller.actions) <| Controller.Initialize feelings