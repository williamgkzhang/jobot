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
#   jobot lunch pick X - sets your lunch pick
#   jobot lunch leave - leave the lunch club
#   jobot lunch site - links to the lunch site
#
# Notes:
#   You gonna need a Firebase with the right data.
#
# Author:
#   flipxfx
module.exports = (robot) ->
  moment = require "moment"
  require "moment-range"
  # Ghetto load until this is done https://github.com/github/hubot/pull/1154
  require("dotenv").config
    silent: true
    path: ".env"

  # Setup firebase database
  firebase = require "firebase"
  firebase.initializeApp
    serviceAccount:
      projectId: process.env.FIREBASE_PROJECT_ID
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL
      privateKey: process.env.FIREBASE_PRIVATE_KEY
    databaseURL: process.env.FIREBASE_DATABASE_URL
  database = firebase.database()

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
          list += "*#{user.name}#{if user.pick then " - #{user.pick}" else ''}*"
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

  # Set lunch pick
  robot.respond /lunch pick (.+)$/i, (msg) ->
    user = @robot.brain.data.users[msg.message.user.id]
    database.ref("lunch/users/#{user.id}").once("value").then (snapshot) ->
      if snapshot.val()
        database.ref("lunch/users/#{user.id}").update pick: msg.match[1]
        msg.send "@#{user.name} set lunch pick to *#{msg.match[1]}*"
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
