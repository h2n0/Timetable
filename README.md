# Timetable
A simple web app to easy filter out correct lecture times for students.

Build using.

* Ruby => Sinatra and Nokogiri, used primarily to server and parse information

* Python => To generate some crawler scripts

* Bash => To automate some cron jobs

## Project tree

*  [App](./app)
* *  [Views](./app/views)

### App
The base of the server, here you will be abe to find all of the routing used to serve pages as well as some helper programs.

### Views
All of the erb templates for pages that may be served up.

* [Index](./app/views/index.erb) - is called when the user first lands on the page
* [User](.app/views/user.erb) - Is called when the user has supplied a valid student ID


