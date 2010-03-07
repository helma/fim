class Command

	attr_accessor :input

	def initialize(input=nil)
		@input = input
	end

	def handle(k)
		case k
		when "\n"
			case @input
			when /^filter/
				items = @input.split(/\s+/)
				@input = items.first + "'" + items[1] + "'" # paranthesis for string argument
			end
			begin
				eval "@@display.#{@input}"
			rescue => e
				alert "Cannot evaluate #{@input} #{e.message} #{e.backtrace}"
			end
			@input = '' 
		when :backspace
			@input.slice!(-1)
		else
			@input += k
		end
	end

end

