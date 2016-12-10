require 'rest-client'

def read_access_token
	filename = 'ACCESS_TOKEN'
	File.exist?(filename) ? File.read(filename) : ARGV[0]
end	

abort 'I need a classroom access token to do my job. Place it on a file named ACCESS_TOKEN or pass it as an argument of this script.' unless read_access_token

@access_token = read_access_token

@organization = 'pdep-utn'
@course = '2016-lunes-manana'
@guides = {
	composition: ['valores-y-funciones', 'practica-valores-y-funciones'],
	conditionals: ['funciones-partidas-pattern-matching-tuplas'],
	pattern_matching: ['practica-funciones-partidas'],
	lists: ['listas'],
	recursion: ['recursividad', 'practica-recursividad']
}

def data_for_guide(guide)
	guide_prefix = 'pdep-utn/mumuki-guia-funcional-'
	url = "http://#{@organization}.classroom-api.mumuki.io/courses/#{@course}/guides/#{guide_prefix}#{guide}"
	RestClient.get url, {:Authorization => "Bearer #{@access_token}"}
end

puts data_for_guide 'valores-y-funciones'