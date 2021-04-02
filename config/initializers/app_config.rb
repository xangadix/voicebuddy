puts "loading error codes ... "
require 'open-uri'
require 'json'

# Go fetch the contents of a URL & store them as a String
# page 1 error codes
data = URI.open('https://spreadsheets.google.com/feeds/cells/1nkXr4HbyaEZw1gY5Ii8mcBjXIu2Xg2bpvjWfvow7t7I/2/public/full?alt=json').read
       .then { |body| JSON.parse(body) }

temp = []
i = 0
data["feed"]["entry"].each do |entry|
  entryrow = entry["gs$cell"]["row"].to_i - 1
  Rails.logger.debug entryrow
  if temp[ entryrow ].nil?
    temp[ entryrow ] = {}
    i+=1
  end

  temp[ entryrow ]["id"]           = i-1
  temp[ entryrow ]["category"]     = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 1
  temp[ entryrow ]["tags"]         = entry["gs$cell"]["$t"].gsub(' ', '').split(',') if entry["gs$cell"]["col"].to_i == 2
  temp[ entryrow ]["oefening"]     = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 3
  temp[ entryrow ]["naam"]         = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 4
  temp[ entryrow ]["doel"]         = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 5
  temp[ entryrow ]["frequentie"]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 6
  temp[ entryrow ]["materiaal"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 7
  temp[ entryrow ]["videobestand"] = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 8
  temp[ entryrow ]["thumbnail"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 9
  temp[ entryrow ]["status"]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 10 # n/u
end

temp = temp.slice(1,1000) # remove headers
Rails.logger.debug "got #{temp.count} records for exercises!"
Rails.logger.debug temp[0].inspect
EXERCISES = temp
