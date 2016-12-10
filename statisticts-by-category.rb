require 'json'
require 'rest-client'

def read_access_token
	filename = 'ACCESS_TOKEN'
	File.exist?(filename) ? File.read(filename) : ARGV[0]
end	

abort 'I need a classroom access token to do my job. Place it on a file named ACCESS_TOKEN or pass it as an argument of this script.' unless read_access_token

@access_token = read_access_token

@organization = 'pdep-utn'
@course = '2016-lunes-manana'
@categories = {
	composition: ['valores-y-funciones', 'practica-valores-y-funciones'],
	conditionals: ['funciones-partidas-pattern-matching-tuplas'],
	pattern_matching: ['practica-funciones-partidas'],
	lists: ['listas'],
	recursion: ['recursividad', 'practica-recursividad']
}

def make_slug(guide)
	"pdep-utn/mumuki-guia-funcional-#{guide}"
end

def fetch_guide_progress(name)
	url = "http://#{@organization}.classroom-api.mumuki.io/courses/#{@course}/guides/#{make_slug name}"
	JSON.parse(RestClient.get url, {:Authorization => "Bearer #{@access_token}", :accept => :json})['guide_students_progress']
end

def stats_for_guide(name)
	fetch_guide_progress(name)
	.map do |progress|
		student = progress['student']
		{ student: "#{student['first_name']} #{student['last_name']}", exercises: progress['stats'] }
	end
	.sort_by { |x| x[:student] }
end

def sum_stat(acum, elem, field)
	acum[field] + elem[field.to_s].to_i
end

def aggregate_stats(stats)
	stats
	.map {|s| s[:exercises]}
	.inject(passed: 0, failed: 0, passed_with_warnings: 0) do |acum, elem|
		{ passed: sum_stat(acum, elem, :passed), failed: sum_stat(acum, elem, :failed), passed_with_warnings: sum_stat(acum, elem, :passed_with_warnings) }
	end
end

def stats_for_category(name)
	@categories[name]
		.flat_map {|g| stats_for_guide g}
		.group_by {|g| g[:student]}
		.map {|student, stats| { student: student, exercises: aggregate_stats(stats) }}
end

puts stats_for_category :composition