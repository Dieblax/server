require 'socket'
require 'mime/types'
require 'json'
require 'erb'

# Server
class Server

	def initialize(port = 2000)
		run(port)
	end

	private
	
	def get(path)
		message = ""

		if Dir.glob("./*").include?("#{path}")
			message = "HTTP/1.1 200 OK\r\n"
		else
			message = "HTTP/1.1 404 Not Found\r\n"
			path = "./not_found.html"
		end

		body = File.read(path)
		headers = "#{date}#{last_modified(path)}#{type(path)}#{length(body)}\r\n"		
		return message + headers + body
	end

	def post(path, params)
		thanks_letter = File.read "./thanks.html"
		to_yield = File.read "./to_yield.html"
		to_yield_erb = ERB.new(to_yield).result(binding)
		@erb_template = ERB.new thanks_letter
		message = ""
		body = ""
		if Dir.glob("./*").include?("#{path}")
			message = "HTTP/1.1 200 OK\r\n"
			body = render { to_yield_erb }
			length = "Content-length: #{body.size}"
			headers = "#{date}#{last_modified(path)}#{type(path)}#{length(body)}\r\n"
		else
			message = "HTTP/1.1 404 Not Found\r\n"
			path = "./not_found.html"
			body = File.read(path)
			headers = "#{date}#{last_modified(path)}#{type(path)}\r\n"
		end
		
		return message + headers + body
	end

	def date
		return "Date: #{Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S %Z")}"
	end

	def last_modified(path)
		return "Last-modified: #{File.mtime(path).gmtime.strftime("%a, %d %b %Y %H:%M:%S %Z")}\r\n"
	end

	def length(body)
		return "Content-length: #{body.size}\r\n"
	end

	def render
		@erb_template.result(bind { yield })
	end

	def bind
		binding
	end

	def type(path)
		ext = path.split(".")[2]
		mime_type = MIME::Types.type_for("#{ext}")
		return "Content-type: #{mime_type[0]}\r\n"
	end

	def bad_request
		return "HTTP/1.1 400 Bad Request"
	end

	def get_method(request)
		return request.scan(/^(GET|POST) /).flatten![0]
	end

	def get_path(request)
		return ".#{request.scan(/ (\/.*) HTTP/).flatten[0]}"
	end

	def run(port)
		@server = TCPServer.open(port)
		loop do 
			$/ = "\r\n\r\n"
			client = @server.accept
			request = client.gets
			method = get_method(request)
			path = get_path(request)
	
			case method
			when "GET" then client.print get(path)
			when "POST" 
				params = JSON.parse(client.gets)
				client.print post(path, params)
			else
				client.print bad_request
			end
			client.close
		end
	end
end

s = Server.new

