# Web-Crawler
Crawl a single domain and generate its site map
# ====== How to run the code =====
crawler = Crawler.new(ARGV[0])
test_output = crawler.crawl!
puts test_output
# ===== sample output =====

[
  {
    "url": ''
    "links": []
    "assets": []
  },
  {
    "url": ''
    "links": []
    "assets": []
  }
]
# This output can be used further to store in DB

