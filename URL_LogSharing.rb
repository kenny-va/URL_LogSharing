require 'uri'


#TO DO'S


if ARGV[0].nil?
    filename = './data-ios/urlLogSharing_2.txt'
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
            hf_loc.write(line.slice(26,500))
        elsif line.include? 'gannett.demdex.net' or line.include? 'repdata.usatoday.com'
            hf_omn.write(line.slice(26,500))
        elsif line.include? 'pubads.g.doubleclick.net'
            hf_ads.write(line.slice(26,500))
        elsif line.include? 'sb.scorecardresearch.com'
            hf_com.write(line.slice(26,500))
        end

    end #each file record

end #open file

hf_ads.close
hf_omn.close
hf_loc.close
hf_com.close




