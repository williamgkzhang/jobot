# Description:
#   jobot likes restaurants and so do we
#
# Configuration:
#   ZOMATO_API_KEY
#
# Commands:
#   jobot restaurant - responds with restaurant info
#
# Author:
#   flipxfx
module.exports = (robot) ->
  # Ghetto load until this is done https://github.com/github/hubot/pull/1154
  require("dotenv").config
    silent: true
    path: ".env"

  # Get restaurant info
  robot.respond /restaurant (.+)$/i, (msg) ->
    query = msg.match[1]
    msg.http("https://developers.zomato.com/api/v2.1/search")
      .query(entity_id: 772, entity_type: "city", q: query)
      .headers("user-key": process.env.ZOMATO_API_KEY, Accept: "application/json")
      .get() (err, res, body) ->
        restaurants = JSON.parse(body).restaurants
        if restaurants.length > 0
          restaurant = restaurants[0].restaurant
          msg.send
            attachments: [
              fallback: "I found this for #{query}: #{restaurant.name} - #{restaurant.url}"
              color: "#{restaurant.user_rating.rating_color}"
              pretext: "I found this for #{query}"
              title: restaurant.name
              title_link: restaurant.url
              thumb_url: restaurant.thumb
              fields: [
                value: restaurant.location?.address || "-"
                short: true
              ,
                value: "<#{restaurant.menu_url}|Menu>"
                short: true
              ,
                title: "Cuisines"
                value: restaurant.cuisines || "-"
                short: true
              ,
                title: "Cost"
                value: Array(restaurant.price_range).join("$") || "-"
                short: true
              ]
            ]
        else
          msg.send "No restaurant found for #{query} :sadpanda:"
