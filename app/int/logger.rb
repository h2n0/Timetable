class Logger
	def initialize(loc)
		@loc = loc
		Dir.mkdir(@loc) unless File.exists?(@loc)
		#@num = Dir[File.join(@loc, '**', '*')].count {|file| File.file?(file)}
		log("Server initialize")
		puts "Running logger!"
	end
	
	def getTimestamp()
		t = Time.now
		return "[#{t.year}-#{t.month}-#{t.day} @ #{t.hour}:#{t.min}:#{t.sec}]"
	end
	
	def log(msg)
		File.open("#{@loc}/log.txt", "a") do |f|
			f.write("#{getTimestamp()} #{msg}\n")
		end
	end
	
	def err(msg)
		log("[ERROR!] #{msg}")
	end
	
	def close()
		log("Server closed!")
		puts "Logger stopping!"
	end
end
