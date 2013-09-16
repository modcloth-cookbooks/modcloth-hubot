# Description:
#   Generates herp for Hubot.
#
# Commands:
#   hubot herp - Displays herp
#
# Notes:
#   None

module.exports = (robot) ->
  robot.respond /herp/, (msg) ->
    msg.send process.env.HERP
