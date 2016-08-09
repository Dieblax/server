require 'socket'
require 'json'  
               
headers = ""
body = ""


#headers, body = response.split("\r\n\r\n", 2)              


class Client
	def initialize(port = 2000)
		run(port)
	end

	def run(port)
		@host = 'localhost'
		path = ''  
		method = get_method
		headers = ""
		body = ""
		if method == "POST"
			headers, body = post_request
			path = '/thanks.html'
		else
			headers, body = get_request
			path = '/index.html'
		end

		request = "#{method} #{path} HTTP/1.1 \r\n#{headers}\r\n"   
		socket = TCPSocket.open(@host, port)
		socket.print(request + body)
		response = socket.read 
		puts response
	end

	def get_method
		begin
			puts "What request do you want to make?"
			method = gets.chomp.upcase
			unless method == "POST" || method == "GET"
				raise "Invalid method #{method}"
			end
			return method
		rescue Exception => e
			puts "#{e}, please retry"
			retry
		end
	end

	def post_request
		viking_hash = Hash.new { |hash, key| hash[key] = {} }
		puts "What will your Viking's name be?"
		name = gets.chomp.capitalize
		viking_hash[:viking][:name] = name
		puts "What will your Viking's email be?"
		email = gets.chomp
		viking_hash[:viking][:email] = email
		body = viking_hash.to_json + "\r\n\r\n"
		length = "Content-length: #{body.size}"
		headers = "Host: #{@host}\r\n#{date}\r\n#{length}\r\n"
		return headers, body
	end

	def get_request
		headers = "Host: #{@host}\r\n#{date}\r\n\r\n"
		body = ""
		return headers, body
	end

	def date
		return "Date: #{Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S %Z")}"
	end
end                    

c = Client.new                         