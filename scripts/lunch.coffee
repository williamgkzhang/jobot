# Description:
#   jobot likes food and so do we
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
#   jobot lunch - responds with the lunch schedule
#   jobot lunch join - join the lunch club, resets user info and pick
#   jobot lunch pick - displays your lunch pick
#   jobot lunch picks - displays all current lunch picks
#   jobot lunch pick X - sets your lunch pick
#   jobot lunch leave - leave the lunch club
#   jobot lunch site - links to the lunch site
#   jobot lunch skip - sets current picker to next in list
#   jobot lunch unskip - sets current picker to previous in list
#
# Notes:
#   You gonna need a Firebase with the right data.
#
# Author:
#   flipxfx
module.exports = (robot) ->
  Moment = require "moment"
  MomentRange = require "moment-range"
  moment = MomentRange.extendMoment(Moment)

  # Get firebase database
  database = require("../lib/firebase-database")()

  # Gets the lunch schedule
  getSchedule = (callback) ->
    database.ref("lunch").once("value").then (snapshot) ->
      lunch = snapshot.val()

      # Build sorted user list
      users = []
      for id, user of lunch.users
        user.id = id
        users.push user
      users.sort (a, b) -> a.name.toLowerCase().localeCompare(b.name.toLowerCase())

      # Starting pick date for the first user
      baseDate = moment lunch.base.date

      # Calculate current date
      currentDate = moment().startOf "day"
      if currentDate.day() > baseDate.day()
        currentDate.day baseDate.day() + 7
      else
        currentDate.day baseDate.day()

      # Calculate current user
      weekDiff = moment.range(baseDate, currentDate).diff "weeks"
      currentUser = weekDiff % users.length

      # Build user list
      list = ""
      for user, index in users
        unless index is currentUser
          list += "#{user.name}"
        else
          list += "*#{user.name} - #{if user.pick then user.pick else "TBD"}*"
        list += ", " unless index is users.length - 1

      callback("*#{currentDate.format "dddd, MMMM D"}* | #{list}")

  # Lunch schedule
  robot.respond /lunch$/i, (msg) ->
    getSchedule (schedule) ->
      msg.send schedule

  # Join lunch club
  robot.respond /lunch join$/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch/users/#{user.id}").set
      name: user.slack.profile.first_name
      pick: ""
    msg.send "@#{user.name} joined the lunch club :thumbsup: :tada:"

  # Display lunch pick
  robot.respond /lunch pick$/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch/users/#{user.id}").once("value").then (snapshot) ->
      if snapshot.val()
        pick = snapshot.val().pick
        if pick
          msg.send "@#{user.name}'s lunch pick is *#{snapshot.val().pick}*"
        else
          msg.send "@#{user.name} has no lunch pick :slightly_frowning_face:"
      else
          msg.send "@#{user.name} is not in the lunch club :thumbsdown:"

  # Display lunch picks
  robot.respond /lunch picks$/i, (msg) ->
    database.ref("lunch/users").once("value").then (snapshot) ->
      # Build sorted user list
      users = []
      for id, user of snapshot.val()
        user.id = id
        users.push user
      users.sort (a, b) -> a.name.toLowerCase().localeCompare(b.name.toLowerCase())

      list = ""
      for user, index in users
        list += "- #{user.name} - #{if user.pick then user.pick else "TBD"}\n"

      msg.send list

  # Set lunch pick
  robot.respond /lunch pick (.+)$/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch/users/#{user.id}").once("value").then (snapshot) ->
      if snapshot.val()
        if msg.match[1].length <= 40
          database.ref("lunch/users/#{user.id}").update pick: msg.match[1]
          msg.send "@#{user.name} set lunch pick to *#{msg.match[1]}*"
        else
          msg.send "@#{user.name} tried to set the lunch pick some obnoxiously long name :disapproval:"
      else
        msg.send "@#{user.name} is not in the lunch club :thumbsdown:"

  # Leave lunch club
  robot.respond /lunch leave$/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch/users/#{user.id}").set null
    msg.send "@#{user.name} left the lunch club :thumbsdown:"

  # Skip lunch for current turn
  robot.respond /lunch skip/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch").once("value").then (snapshot) ->
      lunch = snapshot.val()
      baseDate = moment lunch.base.date
      baseDate.add(-7, 'days')
      database.ref("lunch/base").update date: baseDate.format "YYYY-MM-DD"
      getSchedule (schedule) ->
        msg.send "Lunch skipped"
        msg.send schedule

  # Unskip lunch for current turn
  robot.respond /lunch unskip/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch").once("value").then (snapshot) ->
      lunch = snapshot.val()
      baseDate = moment lunch.base.date
      baseDate.add(7, 'days')
      database.ref("lunch/base").update date: baseDate.format "YYYY-MM-DD"
      getSchedule (schedule) ->
        msg.send "Lunch unskipped"
        msg.send schedule

  # Open the lunch site
  robot.respond /lunch site$/i, (msg) ->
    msg.send "http://flipxfx.com/lunch"
