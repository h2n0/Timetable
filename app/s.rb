#!/usr/bin/ruby

require "sinatra"
require "sinatra/cookies"
require "date"
require_relative "int/parse.rb"
require_relative "int/logger.rb"
require_relative "int/gcal.rb"

enable :sessions
set :session_secret, "setme"

f = Nokogiri::HTML(open("int/timetable"))
t = Timetable.new(f)
log = SWLogger.new("public/logs/")


# Needed to keep cookies around for more than a single session
set(:cookie_options) do
  { :expires => Time.now + 3600*24*7 }
end

get "/" do
	erb :index
end

# User is sent here why the update their settings
get "/user/:id/cols/*/*/*/*" do
	parts = params["splat"]
	name = parts[0]
	
	parts[3].slice!("/")
	
	cols = cookies[:"#{name}"]
	cols = "rgb(#{parts[1]},#{parts[2]},#{parts[3]})"
	
	cookies[:"#{name}"] = cols
	
	redirect "/user/#{params['id']}/"
end

get "/user" do
	id = session[:id]
	
	if id == nil
		redirect "/"
	end
	
	redirect "/user/#{id}/"
end

get "/user/:id/*/json" do
	n = params["id"]
	s = Student.fromNumber(n)
	if s == nil
		log.log("Unable to find user info for ID: #{n}\n#{params}")
		redirect "/"
	else
		log.log("Found info for user with ID: #{n}")
		tom = params["splat"][0]
		hour = 8
		day = tom == nil ? (Time.now.wday - 1) : tom.to_i
		if tom == "tomorrow"
			tday = Time.now.wday
			t.getDay(tday)
			day = tday
		elsif tom == "0"
			t.getDay(0)
		elsif tom == "1"
			t.getDay(1)
		elsif tom == "2"
			t.getDay(2)
		elsif tom == "3"
			t.getDay(3)
		elsif tom == "4"
			t.getDay(4)
		else
			t.getToday()
			hour = Time.now.hour
		end
	end		
	content_type :json
	t.getLectures(s).to_json
end

# User is looking at either today or tomorrow's timetable
get "/user/:id/:tom?" do
	n = params["id"]
	s = Student.fromNumber(n)
	colors = cookies[:colors]
	if s == nil
		log.log("Unable to find user info for ID: #{n}\n#{params}")
		erb :index, :locals => {:err => "No data on that user"}
	else
		log.log("Found info for user with ID: #{n}")
		tom = params["tom"]
		hour = 8
		day = tom == nil ? (Time.now.wday - 1) : tom.to_i
		if tom == "tomorrow"
			tday = Time.now.wday
			t.getDay(tday)
			day = tday
		elsif tom == "0"
			t.getDay(0)
		elsif tom == "1"
			t.getDay(1)
		elsif tom == "2"
			t.getDay(2)
		elsif tom == "3"
			t.getDay(3)
		elsif tom == "4"
			t.getDay(4)
		else
			day = Time.now.wday - 1
			t.getToday()
			hour = Time.now.hour
		end
		
		days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
		cols = cookies.select{|k| k.start_with? "CS"}
		
		# Just to keep the cookies on the system
		if cols != nil
			cookies.each do |c|
				cookies[c[0]] = c[1]
			end
		end
		session[:id] = n
		erb :user, :locals => {:id => n, :hour => hour, :lecs => t.getLectures(s), :colors => cols, :day => days[day]}
	end
end

# We got some feedback data
post "/feedback" do
	name = params["name"]
	id = params["id"]
	dets = params["dets"]
	ti = Time.now
	n = "#{ti.year}-#{ti.month}-#{ti.day}-#{ti.hour}:#{ti.min}:#{ti.sec}"
	
	suc = false
	begin
		File.open("public/feedback/#{n}.txt", "w") do |f|
			f.write("Name: #{name}\n")
			f.write("ID: #{id}\n")
			f.write("Details: #{dets}\n")
		end
		log.log("Feedback was posted")
		suc = true
	resuce
		log.log("Error posting feedback")
	end
	erb :error, :locals => {:done => suc}
end

# User is giving us some feedback
get "/feedback/:id?" do
	erb :error, :locals => {:id => params["id"]}
end

get "/permCall" do
	client_secrets = Google::APIClient::ClientSecrets.load
  auth_client = client_secrets.to_authorization
  auth_client.update!(
    :scope => 'https://www.googleapis.com/auth/calendar',
    :redirect_uri => url('/permCall'))
  if request['code'] == nil
    auth_uri = auth_client.authorization_uri.to_s
    redirect to(auth_uri)
  else # The request is good so we can return to /gcal
    auth_client.code = request['code']
    auth_client.fetch_access_token!
    auth_client.client_secret = nil
    session[:credentials] = auth_client.to_json
    session[:exp] = Time.now + auth_client.expiry
    puts session[:credentials]
    id = session[:id]
    log.log("Successfully got OAuth code")
    redirect "/gcal"
  end
end

get "/gcal" do
	id = session[:id] || -1
	
	if id == -1 # User hasn't done anything yet 
		redirect "/"
	end
	
	unless session.has_key?(:credentials)
		redirect to('/permCall')
	end
	
	if session[:exp] != nil
		if Time.now > session[:exp]
			redirect "/permCall"
		end
	end
	client_opts = JSON.parse(session[:credentials])
	auth_client = Signet::OAuth2::Client.new(client_opts)
	ecal = EasyCalendar.new(auth_client)
	cal = ecal.getCalendarByName("Uni Timetable")
	s = Student.fromNumber(id)
	t.getDay(Time.now.wday)
	lecs = t.getLectures(s)
	log.log("Going to add events to a google calendar for ID: #{id}")
	if lecs.length == 0
		puts "No events to add"
	else	
		ti = Time.now + 60*60*24
		date = "#{ti.year}-#{ti.month}-#{ti.day}"
		tomLecs = ecal.getEventsForXDaysTime(cal, 1) #Get tomorrow's events (Lectures)
		if tomLecs.items.length == 0 # No events tomorrow just add them
			lecs.each do |l|
				s = l.getStart()
				len = l.getLength()
				event = ecal.createEvent(l.getName(), {:date => date, :hour => s, :length => len , :location => l.getLocation()})
				ecal.addEvent(cal, event)
			end
		else # Some events tomorrow so we need to see if they are ours
			if tomLecs.items.length == lecs.length
				for i in 0..lecs.length
					cl = lecs[i]
					ctl = tomLecs.items[i]
					if cl.getName() == ctl.summary  # Do they have the same name
						next
					else
						s = cl.getStart()
						len = cl.getLength()
						event = ecal.createEvent(cl.getName(), {:date => date, :hour => s, :length => len , :location => cl.getLocation()})
						ecal.addEvent(cal, event)
					end
				end
			end
		end
	end
	""
end


# Simple error correction page
error 404 do
	log.err("Something wasn't found\n#{params}")
	redirect "/"
end
