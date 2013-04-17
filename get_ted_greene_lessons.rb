# encoding: utf-8
#
require 'open-uri'
require 'nokogiri'

# This isn't the fastest way to retrieve files, but it's simple.

BASE_DIR = './pdfs'
BASE_URL = 'http://tedgreene.com/teaching/default.asp'

Dir.mkdir(BASE_DIR) unless Dir.exists?(BASE_DIR)
Dir.chdir(BASE_DIR) do |dir|

  doc = Nokogiri::HTML(open(BASE_URL))
  doc.search('span.leading2 a').each do |lesson_type|

    lesson_page_uri = URI.parse(BASE_URL) + URI.escape(lesson_type['href'])
    lesson_page = Nokogiri::HTML(open(lesson_page_uri))
    lesson_page.search('td.verdana12spaced table td').each_slice(2) do |name_td, url_td|

      url_td_a = url_td.at('a')
      next unless url_td_a

      pdf_url = lesson_page_uri + URI.escape(url_td_a['href'])
      pdf_filename = URI.unescape(File.basename(pdf_url.to_s))

      print "Reading: #{ pdf_filename }... "
      if File.exists?(pdf_filename)
        puts "already exists."
        next
      end

      begin
        start_time = Time.now
        File.write(pdf_filename, open(pdf_url).read)
        end_time = Time.now
        File.open('Ted Green lessons.txt', 'a') do |fo|
          fo.puts "#{ name_td.text }\t#{ pdf_filename }"
        end
        puts "finished in %0.2f seconds." % (end_time - start_time)
      rescue Timeout::Error => e
        puts "timed out."
      rescue Exception => e
        STDERR.puts e.message
      end

    end
  end
end
