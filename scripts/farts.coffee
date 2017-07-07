# Description:
#   jobot farts and so do we
#
# Dependencies:
#   "firebase": "^3.0.5"
#
# Configuration:
#   FIREBASE_PROJECT_ID
#   FIREBASE_CLIENT_EMAIL
#   FIREBASE_PRIVATE_KEY
#   FIREBASE_DATABASE_URL
#
# Commands:
#   jobot farts - displays the current number of farts
#   farts+X - increases fart counter by X (0-9)
#   farts-X - decreases fart counter by X (0-9)
#
# Notes:
#   You gonna need a Firebase with the right data.
#
# Author:
#   flipxfx
module.exports = (robot) ->
  # Get firebase database
  database = require("../lib/firebase-database")()

  # Add farts
  robot.respond /farts$/i, (msg) ->
    database.ref("farts/count").once("value").then (snapshot) ->
      msg.send ":clap: *#{snapshot.val()}* farts :dash:"

  # Add farts
  robot.hear /(?:^|\s)farts\+(\d)(?:$|\s)/i, (msg) ->
    database.ref("farts/count").once("value").then (snapshot) ->
      count = +snapshot.val() + +msg.match[1]
      database.ref("farts").update count: count
      msg.send ":upvote: *#{count}* farts :dash:"

  # Remove farts
  robot.hear /(?:^|\s)farts\-(\d)(?:$|\s)/i, (msg) ->
    database.ref("farts/count").once("value").then (snapshot) ->
      count = +snapshot.val() - +msg.match[1]
      count = 0 if (count < 0)
      database.ref("farts").update count: count
      msg.send ":downvote: *#{count}* farts :dash:"
