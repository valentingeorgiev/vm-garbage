require 'net/http'
require 'uri'
require 'timeout'

@sectors = [1, 2, 3, 5, 6, 7, 8, 4, 10, 9]
@host = 'http://172.16.18.217:8080'
@objects = String.new
@flag = true

def get_objects(sector)
	@objects = '/api/sector/' + sector.to_s + '/objects'
	@uo = URI.parse(@host + @objects)
	@resp_uo = Net::HTTP.get_response(@uo).body
end

def get_roots(sector)
	@roots = '/api/sector/' + sector.to_s + '/roots'
	@ur = URI.parse(@host + @roots)
	@resp_ur = Net::HTTP.get_response(@ur).body.split(' ')
end

def collect_garbage
	status = Timeout::timeout(1.1) do
		Net::HTTP.post_form(@uri, 'trajectory' => @objects )
		puts res.body
	end

	rescue Timeout::Error
	  print 's' 

end

def object_check
	tr = @resp_uo.split("\n")


	@resp_ur.each do |y|
		a = []
		tr.each do |x|
			if y == x.split(' ').first
				a << y
				tr.each do |element|
					ax = element.split(' ').first
					bx = element.split(' ').last

					if a.index(bx)
						a.unshift(ax)
						tr.delete(element)
				
					elsif a.index(ax)
						a.push(bx)
						tr.delete(element)
					end
				end
			end
		end

		a.each do |x|
			tr.delete_if { |y| y.split(' ').first == x || y.split(' ').last == x}
		end

	end
	
	tr.shuffle!
	tmp = tr.last
	tr.delete(tmp)
	
	rip = Array.new
	rip << tmp.split(' ').first << tmp.split(' ').last
	
	flag = true
	
	while flag
		tr.each do |element|
			ax = element.split(' ').first
			bx = element.split(' ').last

			if ax==bx then next end

			if rip.first == bx
				flag = true
				rip.unshift(ax)
				tr.delete(element)
				
			elsif rip.last == ax
				rip.push(bx)
				tr.delete(element)
			end
				
		end
		
		flag = false
	end

		@objects = rip.uniq.join(' ')
#		puts "trajectory: #{@objects}"
		collect_garbage
		
	
end

while @flag == true
	@sectors.shuffle!
	sector = @sectors[0]
	get_objects(sector)
	if	get_objects(sector) == nil 
		@sectors.delete(sector)
		next
	elsif @sectors == nil
		@flag = false
	end
	
	get_roots(sector)
	@uri = URI(@host + '/api/sector/' + sector.to_s + '/company/shadow-/trajectory')
#p sector

	object_check
	
end

#puts "SO. DONE."

