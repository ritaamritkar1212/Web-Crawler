require_relative 'crawler.rb'

crawler = Crawler.new(ARGV[0])
test_output = crawler.crawl!
puts test_output