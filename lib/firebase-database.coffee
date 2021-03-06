# Get the configured firebase database
#
# Require like `database = require("../lib/firebase-database")()`

# Ghetto load until this is done https://github.com/github/hubot/pull/1154
require("dotenv").config
  silent: true
  path: ".env"

admin = require "firebase-admin"

module.exports = ->
  # Init app if needed
  if (!admin.apps.length)
    admin.initializeApp
      credential: admin.credential.cert
        projectId: process.env.FIREBASE_PROJECT_ID
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL
        privateKey: process.env.FIREBASE_PRIVATE_KEY
      databaseURL: process.env.FIREBASE_DATABASE_URL

  admin.database()
