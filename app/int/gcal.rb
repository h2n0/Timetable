require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'
require 'json'


class EasyCalendar
	def initialize(auth)
		@service = Google::Apis::CalendarV3::CalendarService.new
		@service.authorization = auth
	end
	
	def getCalendarByName(name)
		cals = @service.list_calendar_lists()
		res = cals.items.select{|l| l.summary == name}
		if res.length == 0
			return nil
		else
			return res[0]
		end
	end
	
	def addNewCalendar(name)
		calendar = Google::Apis::CalendarV3::Calendar.new(
  		summary: name
  	)
  	return @service.insert_calendar(calendar)
	end
	
	def createEvent(name, info)
		hour = info[:hour]
		minute = (info[:minute] || 00)
		endHour = hour + (info[:length] || 1)
		date = info[:date]
		
		t = Time.now
		
		entry = Google::Apis::CalendarV3::Event.new(
			summary: name,
			location: info[:location],
			description: "",
			start: {
				date_time: "#{date}T#{hour}:#{minute}:00",
				time_zone: "Etc/UTC"
			},
			end: {
				date_time: "#{date}T#{endHour}:#{minute}:00",
				time_zone: "Etc/UTC"
			}
		)
		return entry
	end
	
	def getEventsForXDaysTime(calendar, forward)
		day = 60* 60 * 24
		min = Time.now + (day*forward)
		max = min + day
		response = @service.list_events(calendar.id, max_results: 10, single_events: true, order_by: 'startTime', time_min: min.iso8601, time_max: max.iso8601)

	end
	
	def addEvent(calendar, event)
		@service.insert_event(calendar.id, event)
	end

end

=begin
get '/' do
  unless session.has_key?(:credentials)
    redirect to('/callback')
  end
  client_opts = JSON.parse(session[:credentials])
  auth_client = Signet::OAuth2::Client.new(client_opts)
  
  calendar = EasyCalendar.new(auth_client)
  
  cal = calendar.getCalendarByName("Uni Timetable")
  
  if cal == nil
  	puts "Adding a new calendar"
  	cal = calendar.addNewCalendar("Uni Timetable")
  else
  	puts "Found an existing calendar"
  end
  
  ev = calendar.createEvent("CS-110", {:day => 24, :hour => 11, :month => 10, :minute => 0, :length => 2, :location => "Talbot 043"})
  calendar.addEvent(cal, ev)
  

end
=end
