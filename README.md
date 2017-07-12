# jobot
Jobot is a nasty wet slack bot

![](images/jobot.jpg)

## Development
- Make sure you filled out `.env`
- Run `npm run dev`

## Production
- Make sure you have Heroku remote
- Push to Heroku with `git push heroku`

## Commands
```
farts+X - increases fart counter by X (0-9)
farts-X - decreases fart counter by X (0-9)
jobot adapter - Reply with the adapter
jobot clear - jobot licks the screen clean with newlines
jobot echo <text> - Reply back with <text>
jobot farts - displays the current number of farts
jobot help - Displays all of the help commands that Hubot knows about.
jobot help <query> - Displays all help commands that match <query>.
jobot lunch - responds with the lunch schedule
jobot lunch join - join the lunch club, resets user info and pick
jobot lunch leave - leave the lunch club
jobot lunch pick - displays your lunch pick
jobot lunch pick X - sets your lunch pick
jobot lunch picks - displays all current lunch picks
jobot lunch site - links to the lunch site
jobot lunch skip - sets current picker to next in list
jobot lunch unskip - sets current picker to previous in list
jobot ping - Reply with pong
jobot restaurant - responds with restaurant info
jobot run X - displays the result of Javascript X (newlines ok)
jobot run ```X``` - displays the result of Javascript X (easier for newlines)
jobot time - Reply with current time
```
