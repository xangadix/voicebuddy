puts "loading exercises ... "

require 'csv'
require 'open-uri'
require 'json'

def load_csv_data(_file)
  lines = CSV.parse(File.read(_file), headers: false)
  data = {}
  lines[1..10000].each_with_index do |l, i|
    row = {}
    l.each_with_index do |c, j|
      row["cell_#{j}"] = c
    end

    data["row_#{i}"] = row
  end

  return data
end

# Go fetch the contents of a URL & store them as a String
# page 1 error codes
# data = URI.open('https://spreadsheets.google.com/feeds/cells/1nkXr4HbyaEZw1gY5Ii8mcBjXIu2Xg2bpvjWfvow7t7I/1/public/full?alt=json').read
#       .then { |body| JSON.parse(body) }

data = load_csv_data("public/Oefeningenlijst.csv")
temp = []
row = 0

temp = []
i = 0

#puts data

# data["feed"]["entry"].each do |entry|
data.each_with_index do |entry, index|
  # entryrow = entry["gs$cell"]["row"].to_i - 1
  entryrow = index #helper
  # Rails.logger.debug entryrow
  if temp[ entryrow ].nil?
    temp[ entryrow ] = {}
    #i+=1
  end

  # Rails.logger.debug "check #{entry[1]["cell_1"]}"

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
  # temp[ entryrow ]["idea"]                 = entry[1]["cell_0"]  # type
  # temp[ entryrow ]["code"]                 = entry[1]["cell_1"]  # code

  temp[ entryrow ]["id"]                   = entry[1]["cell_0"]
  temp[ entryrow ]["oefening"]             = entry[1]["cell_1"]
  temp[ entryrow ]["frequentie"]           = entry[1]["cell_2"]
  temp[ entryrow ]["materiaal"]            = entry[1]["cell_3"]
  temp[ entryrow ]["status"]               = entry[1]["cell_4"]
  
  temp[ entryrow ]["skip_intro"]           = entry[1]["cell_29"]
  temp[ entryrow ]["skip_twee"]            = entry[1]["cell_30"]

  temp[ entryrow ][ "nl" ] = {} if temp[ entryrow ][ "nl" ].nil?
  temp[ entryrow ][ "nl" ][ "category" ]   = entry[1]["cell_5"]
  temp[ entryrow ][ "nl" ][ "tags" ]       = entry[1]["cell_6"].gsub(' ', '').split(',') unless entry[1]["cell_6"].blank?
  temp[ entryrow ][ "nl" ][ "naam" ]       = entry[1]["cell_7"]
  temp[ entryrow ][ "nl" ][ "doel" ]       = entry[1]["cell_8"]
  temp[ entryrow ][ "nl" ][ "content" ]    = entry[1]["cell_9"]
  temp[ entryrow ][ "nl" ][ "thumbnail" ]  = entry[1]["cell_10"]

  temp[ entryrow ][ "vls" ] = {} if temp[ entryrow ][ "vls" ].nil?
  temp[ entryrow ][ "vls" ][ "category" ]  = entry[1]["cell_11"]
  temp[ entryrow ][ "vls" ][ "tags" ]      = entry[1]["cell_12"].gsub(' ', '').split(',') unless entry[1]["cell_12"].blank?
  temp[ entryrow ][ "vls" ][ "naam" ]      = entry[1]["cell_13"]
  temp[ entryrow ][ "vls" ][ "doel" ]      = entry[1]["cell_14"]
  temp[ entryrow ][ "vls" ][ "content" ]   = entry[1]["cell_15"]
  temp[ entryrow ][ "vls" ][ "thumbnail" ] = entry[1]["cell_16"]

  temp[ entryrow ][ "en" ] = {} if temp[ entryrow ][ "en" ].nil?
  temp[ entryrow ][ "en" ][ "category" ]   = entry[1]["cell_17"]
  temp[ entryrow ][ "en" ][ "tags" ]       = entry[1]["cell_18"].gsub(' ', '').split(',') unless entry[1]["cell_18"].blank?
  temp[ entryrow ][ "en" ][ "naam" ]       = entry[1]["cell_19"]
  temp[ entryrow ][ "en" ][ "doel" ]       = entry[1]["cell_20"]
  temp[ entryrow ][ "en" ][ "content" ]    = entry[1]["cell_21"]
  temp[ entryrow ][ "en" ][ "thumbnail" ]  = entry[1]["cell_22"]

  temp[ entryrow ][ "fr" ] = {} if temp[ entryrow ][ "fr" ].nil?
  temp[ entryrow ][ "fr" ][ "category" ]   = entry[1]["cell_23"]
  temp[ entryrow ][ "fr" ][ "tags" ]       = entry[1]["cell_24"].gsub(' ', '').split(',') unless entry[1]["cell_24"].blank?
  temp[ entryrow ][ "fr" ][ "naam" ]       = entry[1]["cell_25"]
  temp[ entryrow ][ "fr" ][ "doel" ]       = entry[1]["cell_26"]
  temp[ entryrow ][ "fr" ][ "content" ]    = entry[1]["cell_27"]
  temp[ entryrow ][ "fr" ][ "thumbnail" ]  = entry[1]["cell_28"]

  # temp[ entryrow ]["doel"]         = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 6
  # temp[ entryrow ]["frequentie"]   = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 7
  # temp[ entryrow ]["materiaal"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 8
  # temp[ entryrow ]["videobestand"] = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 9
  # temp[ entryrow ]["content"]      = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 10 # appearently more then video
  # temp[ entryrow ]["thumbnail"]    = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 11
  # temp[ entryrow ]["status"]       = entry["gs$cell"]["$t"] if entry["gs$cell"]["col"].to_i == 12 # n/u

end

#temp = temp.slice(1,1000) # remove headers
Rails.logger.debug "got #{temp.count} records for exercises!"
#Rails.logger.debug temp
to_delete = []
temp.each do |t|
  if t["status"] != "1"
    to_delete << t
  end
end
EXERCISES = temp - to_delete
