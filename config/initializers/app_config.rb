puts "loading exercises ... "
require 'open-uri'
require 'json'

# Go fetch the contents of a URL & store them as a String
# page 1 error codes
data = URI.open('https://spreadsheets.google.com/feeds/cells/1nkXr4HbyaEZw1gY5Ii8mcBjXIu2Xg2bpvjWfvow7t7I/1/public/full?alt=json').read
       .then { |body| JSON.parse(body) }

temp = []
i = 0

data["feed"]["entry"].each do |entry|
  entryrow = entry["gs$cell"]["row"].to_i - 1
  # Rails.logger.debug entryrow
  if temp[ entryrow ].nil?
    temp[ entryrow ] = {}
    i+=1
  end

  # preset_id 1
  # oefening  2
  # frequency 3
  # materiaal 4
  # status    5

  # nl
    # Categorie_tags
    # tags
    # naam
    # doel
    # content
    # thumbnail

  # vls
    # Categorie_tags
    # tags
    # naam
    # doel
    # content
    # thumbnail

  # en
    # Categorie_tags
    # tags
    # naam
    # doel
    # content
    # thumbnail

  # fr
    # Categorie_tags
    # tags
    # naam
    # doel
    # content
    # thumbnail


  # if stats == "-1" skip

  temp[ entryrow ]["id"]                   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 1
  temp[ entryrow ]["oefening"]             = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 2
  temp[ entryrow ]["frequentie"]           = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 3
  temp[ entryrow ]["materiaal"]            = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 4
  temp[ entryrow ]["status"]               = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 5

  temp[ entryrow ][ "nl" ] = {} if temp[ entryrow ][ "nl" ].nil?
  temp[ entryrow ][ "nl" ][ "category" ]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 6
  temp[ entryrow ][ "nl" ][ "tags" ]       = entry["gs$cell"]["$t"].gsub(' ', '').split(',') if entry["gs$cell"]["col"].to_i == 7
  temp[ entryrow ][ "nl" ][ "naam" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 8
  temp[ entryrow ][ "nl" ][ "doel" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 9
  temp[ entryrow ][ "nl" ][ "content" ]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 10
  temp[ entryrow ][ "nl" ][ "thumbnail" ]  = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 11

  temp[ entryrow ][ "vls" ] = {} if temp[ entryrow ][ "vls" ].nil?
  temp[ entryrow ][ "vls" ][ "category" ]  = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 12
  temp[ entryrow ][ "vls" ][ "tags" ]      = entry["gs$cell"]["$t"].gsub(' ', '').split(',') if entry["gs$cell"]["col"].to_i == 13
  temp[ entryrow ][ "vls" ][ "naam" ]      = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 14
  temp[ entryrow ][ "vls" ][ "doel" ]      = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 15
  temp[ entryrow ][ "vls" ][ "content" ]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 16
  temp[ entryrow ][ "vls" ][ "thumbnail" ] = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 17

  temp[ entryrow ][ "en" ] = {} if temp[ entryrow ][ "en" ].nil?
  temp[ entryrow ][ "en" ][ "category" ]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 18
  temp[ entryrow ][ "en" ][ "tags" ]       = entry["gs$cell"]["$t"].gsub(' ', '').split(',') if entry["gs$cell"]["col"].to_i == 19
  temp[ entryrow ][ "en" ][ "naam" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 20
  temp[ entryrow ][ "en" ][ "doel" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 21
  temp[ entryrow ][ "en" ][ "content" ]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 22
  temp[ entryrow ][ "en" ][ "thumbnail" ]  = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 23

  temp[ entryrow ][ "fr" ] = {} if temp[ entryrow ][ "fr" ].nil?
  temp[ entryrow ][ "fr" ][ "category" ]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 24
  temp[ entryrow ][ "fr" ][ "tags" ]       = entry["gs$cell"]["$t"].gsub(' ', '').split(',') if entry["gs$cell"]["col"].to_i == 25
  temp[ entryrow ][ "fr" ][ "naam" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 26
  temp[ entryrow ][ "fr" ][ "doel" ]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 27
  temp[ entryrow ][ "fr" ][ "content" ]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 28
  temp[ entryrow ][ "fr" ][ "thumbnail" ]  = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 29

  # temp[ entryrow ]["doel"]         = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 6
  # temp[ entryrow ]["frequentie"]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 7
  # temp[ entryrow ]["materiaal"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 8
  # temp[ entryrow ]["videobestand"] = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 9
  # temp[ entryrow ]["content"]      = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 10 # appearently more then video
  # temp[ entryrow ]["thumbnail"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 11
  # temp[ entryrow ]["status"]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 12 # n/u

end

temp = temp.slice(1,1000) # remove headers
Rails.logger.debug "got #{temp.count} records for exercises!"
Rails.logger.debug temp[4].inspect
to_delete = []
temp.each do |t|
  if t["status"] != "1"
    to_delete << t
  end
end
EXERCISES = temp - to_delete
