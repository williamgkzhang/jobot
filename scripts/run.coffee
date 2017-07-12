# Description:
#   jobot runs a Javascript statement
#
#
# Commands:
#   jobot run X - displays the result of Javascript X (newlines ok)
#   jobot run ```X``` - displays the result of Javascript X (easier for newlines)
#
# Author:
#   flipxfx

helpers = require "../lib/helpers"

module.exports = (robot) ->
  robot.respond /run(?: |\n|\r| ```)([^]+)$/i, (msg) ->
    console.log msg.match[1].replace(/```$/, "")
    msg.http("https://jobot-run-065n9y2ycsx5.runkit.sh")
      .query(run: helpers.replaceWordChars(msg.match[1].replace(/^```/, "").replace(/```$/, "")))
      .headers(Accept: "application/json")
      .get() (err, res, body) ->
        # Get error if any
        error = null
        if err?
          error = err.message
        else
          try
            json = JSON.parse(body)
            error = json.message if json.error
          catch e

        if error?
          msg.send ":boom: *it blowd up*: #{error}"
        else
          msg.send body
