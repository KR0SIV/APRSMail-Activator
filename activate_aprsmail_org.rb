require 'rubygems'
require 'socket'
exit if Object.const_defined?(:Ocra) #allow ocra to create an exe without executing the entire script

class Aprs
  def initialize(server, port, call)
    @server  = server
    @port    = port
	@call = call
  end
  
  def connect
	@socket = TCPSocket.open(@server, @port)
	@socket.puts "#{@server} #{@port}"
	pass = self.passcode(@call.upcase)
	@socket.puts "user #{@call.upcase} pass #{pass} ver \"RubyControl\""
  end
  
  
    def msg_loop()
		4.times do
		msg = @socket.gets
		self.msg_dis(msg)
	 	end
    end

    def close
    	@socket.close
    end
  
  def msg_dis(msg)
	#Thread.new do
		if msg.match(/N6NAR/)
			msg.gsub!(/.*:/, "")
			puts "#{msg}"
		end
	#end
   end

   def send_msg(msg, fromcall)
	data = "#{fromcall}>APDR12,ACTV8M,WIDE1*,qAR,VE3CRC::N6NAR    :#{msg}"
	@socket.puts data
	#puts "Debug(Outgoing msg): #{data}"
    end
  
  def packet(position, comment)
	init = "#{@call.upcase}>APRS,TCPIP*:"
	send = "#{init}#{position} #{comment}"
	#puts "Debug(Outgoing): #{send}"
	puts "Connecting to APRS-IS Network"
	@socket.puts "#{send}"
  end
  
  def passcode(call_sign) ## credit to https://github.com/xles/aprs-passcode/blob/master/aprs_passcode.rb
	call_sign.upcase!
	call_sign.slice!(0,call_sign.index('-')) if call_sign =~ /-/
	hash = 0x73e2
	flag = true
	call_sign.split('').each{|c|
	hash = if flag
	(hash ^ (c.ord << 8))
		else
		(hash ^ c.ord)
		end
	flag = !flag
	}
	hash & 0x7fff
   end
  
  
end
  
  print "Enter callsign: "
  usercallsign = gets.chomp.upcase
  print "Enter Activation Key: "
  activationkey = gets.chomp.upcase
  puts ""
  puts ""


  aprs = Aprs.new("second.aprs.net", 20157, "ACTV8M")
  aprs.connect
  aprs.packet("=4018.19N/07156.81W-", "aprsmail.org activator")
  aprs.send_msg("#{activationkey}", "#{usercallsign}")
  aprs.msg_loop

  puts ""
  puts "Completed"
  puts "Disconnecting from APRS-IS"
  sleep(5)
  aprs.close