# Helper methods

module.exports =
  # Replace fancy quotes etc from Word to regular keyboard chars
  replaceWordChars: (text) ->
    s = text

    # smart single quotes and apostrophe
    s = s.replace(/[\u2018|\u2019|\u201A]/g, "\'")
    # smart double quotes
    s = s.replace(/[\u201C|\u201D|\u201E]/g, "\"")
    # ellipsis
    s = s.replace(/\u2026/g, "...")
    # dashes
    s = s.replace(/[\u2013|\u2014]/g, "-")
    # circumflex
    s = s.replace(/\u02C6/g, "^")
    # open angle bracket
    s = s.replace(/\u2039/g, "")
    # spaces
    s = s.replace(/[\u02DC|\u00A0]/g, " ")
    
    s
