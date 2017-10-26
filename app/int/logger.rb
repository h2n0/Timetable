class SWLogger

	# Construts a new SWLogger
	# @param loc [String] the directory path where the file should be stored
	def initialize(loc)
		@loc = loc
		@open = true
		Dir.mkdir(@loc) unless File.exists?(@loc) # If the dir dosen't exist then make it
		log("Server initialize")
		puts "Running logger!"
	end
	
	# Prints the given argument to the log file
	# @param msg [String] the text the user wants to append to the log file
	def log(msg)
		if !@open
			return
		end
		File.open("#{@loc}/log.txt", "a") do |f|
			f.write("#{getTimestamp()} #{msg}\n")
		end
	end
	
	# Places '[Error!]' before the message
	# @param msg [String] the text the user wants to append to the log file
	def err(msg)
		log("[ERROR!] #{msg}")
	end
	
	# Called when the user no longer needs to log information
	def close()
		@open = false
		log("Logger stopping")
	end
	
	private
	
	# Used to generate a timestamp
	# @return [String] YYYY-MM-DD @ HH:MM:SS
	def getTimestamp()
		t = Time.now
		return "[#{t.year}-#{t.month}-#{t.day} @ #{t.hour}:#{t.min}:#{t.sec}]"
	end
end
