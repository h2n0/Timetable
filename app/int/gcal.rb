require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'
require 'json'


class EasyCalendar

	# @param [Signet::OAuth2::Client] google OAuth
	# @see https://developers.google.com/identity/protocols/OAuth2WebServer OAuth
	def initialize(auth)
		@service = Google::Apis::CalendarV3::CalendarService.new
		@service.authorization = auth
	end
	
	# Get a calendar by its name
	# @param name [String] the name of the calendar that the user is after
	def getCalendarByName(name)
		cals = @service.list_calendar_lists()
		res = cals.items.select{|l| l.summary == name}
		if res.length == 0
			return nil
		else
			return res[0]
		end
	end
	
	# Add a new calendar to the users calendar system
	# @param name [String] the name of the calendar we want to create
	# @return [Google::Apis::CalendarV3::Calendar]
	# @see https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/calendar_v3/service.rb Calendar
	def addNewCalendar(name)
		calendar = Google::Apis::CalendarV3::Calendar.new(
  		summary: name
  	)
  	return @service.insert_calendar(calendar)
	end
	
	# Create a Google calendar event
	# @param name [String] the name of the event we want to create
	# @param info:hour [Int] the starting hour of the event
	# @param info:minute [Int] the start minute of the event
	# @param info:length [Int] the length of the event
	# @param info:date [String] the day the event is going to start on
	# @param info:location [String] the location of the event
	# @return [Google::Apis::CalendarV3::Event]
	# @see https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/calendar_v3/service.rb Event
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
	
	# Get all the evens for X days time
	# @param calendar [Google::Apis::CalendarV3::Calendar] the calendar to look in
	# @param forward [Int] the number of days to look ahead
	# @return [Google::Apis::CalendarV3::Events]
	# @see https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/calendar_v3/service.rb Events
	def getEventsForXDaysTime(calendar, forward)
		day = 60* 60 * 24
		min = Time.now + (day*forward)
		max = min + day
		response = @service.list_events(calendar.id, max_results: 10, single_events: true, order_by: 'startTime', time_min: min.iso8601, time_max: max.iso8601)
		return response
	end
	
	# Add an event to the given calendar
	# @param calendar [Google::Apis::CalendarV3::Calendar] the calendar we want to add to
	# @param event [Google::Apis::CalendarV3::Event] the event we want to add
	# @see #createEvent
	def addEvent(calendar, event)
		@service.insert_event(calendar.id, event)
	end

end
