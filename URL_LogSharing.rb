require 'uri'

x = ''

#TO DO'S
data_directory = './data-ios/'

if ARGV[0].nil?
    filename = data_directory + 'urlLogSharing.txt'
else
    filename = ARGV[0]
end
puts 'File name: ' + filename


# Create files for output
ads_filename = filename.slice(0,filename.rindex('.')) + '_ads.txt'
hf_ads = File.open(ads_filename, 'w')

localytics_filename = filename.slice(0,filename.rindex('.')) + '_localytics.txt'
hf_loc = File.open(localytics_filename, 'w')

omniture_filename = filename.slice(0,filename.rindex('.')) + '_omniture.txt'
hf_omn = File.open(omniture_filename, 'w')

comscore_filename = filename.slice(0,filename.rindex('.')) + '_comscore.txt'
hf_com = File.open(comscore_filename, 'w')

File.open(filename) do |f|       #LOOP THROUGH THE FILE TO PROCESS SPECIFIC LINES
 
    f.each do |line|

        if line.include? 'analytics.localytics.com'
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

# Get the latest files from Artifactory
baseline_localytics_filename = data_directory + 'baseline_localytics.txt'
#baseline_omniture_filename = data_directory + 'baseline_omniture.txt'
#baseline_ads_filename = data_directory + 'baseline_ads.txt'
#baseline_comscore_filename = data_directory + 'baseline_comscore'


=begin
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_localytics_filename -o baseline_localytics_filename ]
# Somehow check status of file download

x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_omniture_filename -o baseline_omniture_filename]
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_ads_filename -o baseline_ads_filename ]
x = %x[curl "https://artifactory.gannettdigital.com/native-apps-node/" + baseline_comscore_filename -o baseline_comscore_filename ]
=end

# Compare Localytics files
baseline_localytics_file = File.open(baseline_localytics_filename, 'r')
new_localytics_file = File.open(localytics_filename, 'r')

while !baseline_localytics_file.eof? and !new_localytics_file.eof?

    base_line = baseline_localytics_file.readline
    new_line = new_localytics_file.readline

    if base_line == new_line
        puts 'Everything is great'
    else
        puts 'Everything is not so great'
    end

end



# Push files to Artifactory
#curl -H 'X-JFrog-Art-Api: <API_KEY>' -T my-artifact.tar "http://artifactory.gannettdigital.com/artifactory/my-repository/my-app/tarballs/my-artifact.tar"
