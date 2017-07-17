require 'uri'
require 'set'
require 'fileutils'

x = ''
ipad = false
iphone = false
data_directory = ''

# Create data directories if they don't exist
def create_dir(dir)
    unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
    end
end

# These are the fields we only check for value existence.  They are different between executions.
verify_content_fields = ',aid,client_id,appID,c_gnt_appID,c_gnt_client_id,d_uuid,d_dpuuid,'

#TO DO'S
source_directory = './'

if ARGV[0].nil?
    filename = 'api-url-logfile.txt'
else
    filename = ARGV[0]
end
puts 'File name: ' + filename

# Determine if this is IPAD or IPHONE
begin
    File.open(source_directory + filename) do |f|       #PARSE MASTER FILE TO CREATE SUB-FILES
        f.each do |line|

            if line.include? 'api.gannett-cdn.com/ping'
                if line.include? 'ios_ipad'
                    ipad = true
                elsif line.include? 'ios_iphone'
                    iphone = true
                end
            end
            if ipad or iphone
                break
            end
        end
    end
rescue
    puts 'Error opening the input file: ' + source_directory + filename
    exit
end

# Set the data directory, creating if necessary
if ipad
    data_directory = source_directory + 'ipad/'
    create_dir('iPad')
elsif iphone
    data_directory = source_directory + 'iphone/'
    create_dir('iPhone')
end

# Create files for output
#ads_filename = data_directory + filename.slice(0,filename.rindex('.')) + '_ads.txt'
puts 'Data directory: ' + data_directory
puts 'Filename: ' + filename

if filename.rindex('/').nil?
    filename = '/' + filename
end
tmpFilename = filename.slice(filename.rindex('/')+1..filename.rindex('.')-1)

ads_filename = data_directory + tmpFilename + '_ads.txt'
hf_ads = File.open(ads_filename, 'w')

localytics_filename = data_directory + tmpFilename+ '_localytics.txt'
hf_loc = File.open(localytics_filename, 'w')

omniture_filename = data_directory + tmpFilename + '_omniture.txt'
hf_omn = File.open(omniture_filename, 'w')

comscore_filename = data_directory + tmpFilename + '_comscore.txt'
hf_com = File.open(comscore_filename, 'w')


File.open(source_directory + filename) do |f|       #PARSE MASTER FILE TO CREATE SUB-FILES

    f.each do |line|

        if line.include? 'localytics'
            hf_loc.write(line.slice(26,line.length-26))
        elsif line.include? 'gannett.demdex.net' or line.include? 'repdata.usatoday.com'
            hf_omn.write(line.slice(26,line.length-26))
        elsif line.include? 'pubads.g.doubleclick.net'
            hf_ads.write(line.slice(26,line.length-26))
        elsif line.include? 'sb.scorecardresearch.com'
            hf_com.write(line.slice(26,line.length-26))
        end

    end #each file record

end #open file

hf_ads.close
hf_omn.close
hf_loc.close
hf_com.close

# Get the latest files from GITHUB
baseline_localytics_filename = data_directory + 'baseline_localytics.txt'
baseline_omniture_filename = data_directory + 'baseline_omniture.txt'
baseline_ads_filename = data_directory + 'baseline_ads.txt'
baseline_comscore_filename = data_directory + 'baseline_comscore.txt'

=begin
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_localytics_filename -o baseline_localytics_filename ]
# Somehow check status of file download

x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_omniture_filename -o baseline_omniture_filename]
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_ads_filename -o baseline_ads_filename ]
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_comscore_filename -o baseline_comscore_filename ]
=end


# Ensure baseline files exist.  If not, create them.
if File.exist?(baseline_localytics_filename)
    puts 'Baseline files exist'
else
    puts 'Baseline files created'
    FileUtils.copy(localytics_filename, baseline_localytics_filename)
    FileUtils.copy(omniture_filename, baseline_omniture_filename)
    FileUtils.copy(ads_filename, baseline_ads_filename)
    FileUtils.copy(comscore_filename, baseline_comscore_filename)
end


# Compare Localytics files
baseline_localytics_file = File.open(baseline_localytics_filename, 'r')
new_localytics_file = File.open(localytics_filename, 'r')

while !baseline_localytics_file.eof? and !new_localytics_file.eof?

    base_line = baseline_localytics_file.readline
    new_line = new_localytics_file.readline

    if base_line == new_line
        puts 'Localytics - Everything is great'
    else
        puts 'Localytics - Everything is not so great'
    end

end

# Compare Comscore files
baseline_comscore_file = File.open(baseline_comscore_filename, 'r')
new_comscore_file = File.open(comscore_filename, 'r')

while !baseline_comscore_file.eof? and !new_comscore_file.eof?

    base_line = baseline_comscore_file.readline
    new_line = new_comscore_file.readline

    if base_line == new_line
        puts 'Comscore - Everything is great'
    else
        puts 'Comscore - Everything is not so great'
    end

end

# Compare Ads files
baseline_ads_file = File.open(baseline_ads_filename, 'r')
new_ads_file = File.open(ads_filename, 'r')

if !baseline_ads_file.eof? or !new_ads_file.eof?
    puts ' '
    puts 'Ads file empty (baseline or new run)'
    puts ' '
end

while !baseline_ads_file.eof? and !new_ads_file.eof?

    base_line = baseline_ads_file.readline
    new_line = new_ads_file.readline

    if base_line == new_line
        puts 'Ads - Everything is great'
    else
        puts ' '
        puts 'Ads difference'
        puts base_line
        puts new_line
        puts ' '
    end

end


# Compare Omniture files
baseline_omniture_file = File.open(baseline_omniture_filename, 'r')
new_omniture_file = File.open(omniture_filename, 'r')

omni_diff = Set.new
line_counter = 1

while !baseline_omniture_file.eof? and !new_omniture_file.eof?

    base_values = baseline_omniture_file.readline
    new_values = new_omniture_file.readline

    if base_values.include? 'gannett.demdex.net' or base_values.include? 'repdata.usatoday.com/b/ss'

        if base_values.include? 'gannett.demdex.net'
            base_values = URI.decode(base_values.slice(base_values.index('gannett.demdex.net/event?'),base_values.length))
            base_values = base_values.slice(base_values.index('?')+1,base_values.length)  #Strip off the domain and API call, leaving just the parameters

        elsif base_values.include? 'repdata.usatoday.com/b/ss'
            base_values = URI.decode(base_values.slice(base_values.index('/ndh')+1,base_values.length))
            base_values = base_values.slice(0,base_values.length-2)
        end

        if new_values.include? 'gannett.demdex.net'
            new_values = URI.decode(new_values.slice(new_values.index('gannett.demdex.net/event?'),new_values.length))
            new_values = new_values.slice(new_values.index('?')+1,new_values.length)  #Strip off the domain and API call, leaving just the parameters

        elsif new_values.include? 'repdata.usatoday.com/b/ss'
            new_values = URI.decode(new_values.slice(new_values.index('/ndh')+1,new_values.length))
            new_values = new_values.slice(0,new_values.length-2)
        end

        # Split the parameters up to individually compare
        base_values = base_values.split('&')
        new_values = new_values.split('&')

        i=1  # Counter for the number of parameters
        while i < base_values.count do

            # Let's validate the field name is the same.  If not, then something is out of sync and we'll
            # ignore the entire line

#            puts 'Base values: ' + base_values[i]
#            puts 'New values: ' + new_values[i]

            begin
                if base_values[i].split('=')[0] == new_values[i].split('=')[0]  # If field names are the same ...

                if base_values[i] == new_values[i]
                    #puts 'Omniture - Everything is great'
                elsif (verify_content_fields.downcase.include? ',' + new_values[i].split('=')[0].downcase + ',') and new_values[i].split('=')[1].downcase.length > 0
                    #puts 'Omniture - Value exists'
                else
                    puts 'Omniture difference. Line: ' + line_counter.to_s
                    puts 'New: ' + base_values[i].to_s
                    puts '-'
                    puts 'Old: ' + new_values[i].to_s
                    puts ' '

                    # Record the Old and New values so we don't report it again
                    omni_diff.add?('Old: ' + base_values[i].to_s + ';<br>New: ' + new_values[i].to_s) + '<br><br>'
                end

                else  # Field names are different.  Something whonky happened.

                    puts 'Base values: ' + base_values.to_s
                    puts '  '
                    puts 'New values: ' + new_values.to_s
                    puts '  '
                    break
                end
            rescue
                puts 'Error splitting base and new values: ' + base_values[i] + '   -   ' + new_values[i]
                exit
            end
            i=i+1
        end
    end

    line_counter = line_counter + 1

end

# Write output to file
hf_output = File.open(data_directory + 'URL_LogSharing_Output.html', 'w')

puts 'Omniture Collection'
if omni_diff.count == 0
    hf_output.write('No differences')
else
    omni_diff.each do |x|
        puts x
        hf_output.write(x)
    end
end
hf_output.close


# POSSIBLE VARIABLES TO IGNORE

# Difference baseline for iphone and ipad
#
# Ignore version, but should be populated
# Add Ruby script to iOS script folder (ask Jon)
# Use GIT for storage

#iphone_build_134 line 100 - &aamsegment=testios%2Cios%2C501%2C508%2C510%2C300  WHY IS THIS IN THERE BUT NOT ALWAYS?
