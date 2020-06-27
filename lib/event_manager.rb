require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

######################################################################################
###### BELOW ARE STEPS TAKEN TO READ IN A FILE TO RUBY, THEY AREN'T ##################
#### THE MOST EFFICIENT, BUT I AM KEEPING THEM AS COMMENTS FOR HISTORICAL REFERANCE ##
######################################################################################
# if File.exist? "../event_attendees.csv"
#     contents = File.read "../event_attendees.csv"
#     puts contents
# end

# read each line from the file and store it in an array (lines). 
# then iterate over and output the content of each line from the array.

# lines = File.readlines "../event_attendees.csv"
# lines.each do |line|
#     puts line
# end

# If we want to look at first names of the attendees, we need to 
# first iscolate the coloumns of data using the column headers.
#split the arrays on the "." then isolate the index for each column that is the first name.

# lines = File.readlines "../event_attendees.csv"
# lines.each do |line|
#     next if line == lines[0] #skip the column headers
#     columns = line.split(",")
#     first_name = columns[2] # its the 3rd column on the table, even though you're selecting this index from a "row".
#     puts first_name
# end

# Ruby provides it own CSV parser (be sure to "require" the library above to load the class and methods).
def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
    ### SAME BELOW, MORE SUCCINCT ABOVE ###
    # if zipcode.nil?
    #     zipcode = "00000"
    # elsif zipcode.length < 5
    #     zipcode = zipcode.rjust 5, "0"
    # elsif zipcode.length > 5
    #     zipcode = zipcode[0..4]
    # else
    #     zipcode
    # end
end

def clean_phone_number(phone_number)
    phone_number = phone_number.to_s.delete('^0-9')
    phone_number[0] == "1" && phone_number.size == 11 ? phone_number.slice!(0) : phone_number
    phone_number.size < 10 || phone_number.size >= 11 ? phone_number = "" : phone_number
end

def get_registration_hour(regdate)
    regdate = regdate.sub("/", "-").sub("/", "/20").sub("/", "-")
    regdate = DateTime.strptime(regdate, "%m-%d-%Y %H:%M")
    reg_hour = regdate.hour
end

def legislators_by_zipcode(zip) # for info on how to set up api, read documentation
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: "country",
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir("output") unless Dir.exists? "output"

    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end
    
puts "EventManager Initialized!"

contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "../form_letter.erb"
erb_template = ERB.new template_letter


# puts hours.max_by { |hour| hours.count(hour) }


# home_phone_numbers = contents.each do |row|
#     id = row[0]
#     first_name = row[:first_name]
#     phone_number = clean_phone_number(row[:homephone])
#     puts "#{id} #{first_name} #{phone_number}"
# end

# contents.each do |row|
#     id = row[0] #this is no header for "id" so we revert back to the index
#     first_name = row[:first_name] #instead of the index, the CSV library allows us to convert the headers into symbols
#     zipcode = clean_zipcode(row[:zipcode])
#     legislators = legislators_by_zipcode(zipcode)
#     form_letter = erb_template.result(binding)

#     save_thank_you_letter(id, form_letter)
# end


