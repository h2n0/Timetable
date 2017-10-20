# Swantime
A simple web app to easy filter out correct lecture times for students.

Build using.

* Ruby => Sinatra and Nokogiri, used primarily to server and parse information

* Python => To generate some crawler scripts

* Bash => To automate some cron jobs

## Project tree

*  [App](./app)
* * [Internal](./app/int)
* *  [Views](./app/views)

### App
The base of the server, here you will be abe to find all of the routing used to serve pages as well as some helper programs.

### Internal
This is where most of the magic happens.

* [parse.rb](./app/int/parse.rb) - This is where the timetable is parsed and turned into an easily navigatable object.
* [cmd.py](./app/int/cmd.py) - This is where we generate the [Lynx](http://http://lynx.browser.org/) command script to get the timetable
* [t.sh](./app/int/t.sh) - This is the script that the cron manager on the server calls when it's time to get a new timetable


### Views
All of the erb templates for pages that may be served up.

* [Index](./app/views/index.erb) - Is called when the user first lands on the page
* [User](.app/views/user.erb) - Is called when the user has supplied a valid student ID
* [Feedback](.app/views/error.erb) - Is called when the user needs to send feedback to us

