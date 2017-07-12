# Description:
#   jobot likes Jon Sudano and so do we
#
# Commands:
#   jobot playit - responds with youtube video
#
# Author:
#   williamgkzhang
#
#



module.exports = (robot) ->
  require("dotenv").config
    silent: true
    path: ".env"
  videos = [ "pBcqxijlbMg", "a96N8W8uCX0", "zQzMB8x59jo", "lJMUurymcHI", "gTwxtYin1p0", "Uef0Qr56mKo", "QbgGIy3kKiM", "EhcpoXqT86A", "royTfXaUb2A", "rDPWw_tqjqI", "u_wSzQNQT8c", "9oMXMj-8Sqg", "zoy6h6hEOVo", "ibAmiaSfKVE", "DLk7mBu_rbQ", "gWDODZqn8y8", "r-Tf96xyH34", "mbu7Mad1-6I", "E9JRAEpi3DM", "io_WzmiDYt4", "eI8Kp1N2PJA", "qOuy455x3h8", "EsJrTY7rRjQ", "E4lzHnX5vD0", "cq-YWK9Dsxo", "0ltMmlILEIE", "IAni_ZdEcPo", "pVRGdNi60Oo", "hKf8xXqd94M", "srvEoj2CaQs", "aOnfUo9LBxg", "609HhzQ6zfU", "aF1KB5O1f2k", "i2EioursdXc", "xA8Qhr_onG8", "X8KXkFxxVrE", "WuPBd2IlEPI", "QO76ok0vo_Y", "c1LQ0NFDzkg", "qkbL1n4iVog", "fXCzxR7fe20", "2eZxIiRLn3w", "kb3SgWiY5mY", "lXOBaYgFod0" ]

  # Get restaurant info
  robot.respond /(?:^|\s)playit(?:$|\s)/i, (msg) ->
    video_id = videos[Math.floor(videos.length * Math.random())]
    video = "https://www.youtube.com/watch?v=" + video_id + "&list=PLPHqjtjDicA6IyQJOnnTPDeEz2XyZ5lb6"
    msg.send
      attachments: [
        fallback: "Check out this video"
        pretext: "Hot video right here"
        title_link: video
      ]
