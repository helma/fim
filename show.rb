class Show

	def handle(k)
		case k
		when 'j'
			@@display.next
		when 'k'
			@@display.previous
		when 'r'
			@@display.rotate
		when 's'
			@@display.image.selected = !@@display.image.selected
			@@display.image.save
		when 'd'
			@@display.image.deleted = !@@display.image.selected
			@@display.image.save
			@@display.next
		when 'a'
			@@display.image.art = !@@display.image.art
			@@display.image.save
		when 'p'
			@@display.image.private = !@@display.image.private
			@@display.image.save
		end
		@@display.reload = true
	end

end

