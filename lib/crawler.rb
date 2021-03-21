require 'nokogiri'
require 'open-uri'
require 'logger'
require 'json'
require 'pry'

class Crawler
  attr_reader :logger, :uri, :site_map, :max_deapth

  def self.cli(args, io = $stdout, err = $stdout, logio = $stderr)
    if args.size != 1
      err.puts "Usage: crawler starting-uri"
      exit 1
    end
    crawler = new(args[0], Logger.new(logio))
    crawler.crawl!
    io.puts JSON.pretty_generate(Crawler::Page.to_a)
  end

  def initialize(url, logger = Logger.new(File.open("log/crawler.log", "a")))
    @start_url = url
    @uri    = URI.parse(url)
    @logger = logger
    @site_map = []
    @max_deapth = 2 
  end

  def crawl!
    logger.info "Starting crawl of #{@start_url}"
    crawl_page @start_url
    while page = next_uncrawled_page
      crawl_page page['url']
    end
    site_map
  end

  def next_uncrawled_page    
    site_map.detect do |page|
      page['links'].nil?
    end
  end

  def crawl_page(url)
    uri = parse_url(url)
    logger.info uri.to_s
    page = parse_page(URI.open(uri).read)
    map_hash = site_map.detect { |page| page['url']  == uri.to_s} || {}
    map_hash['url'] = uri.to_s
    map_hash['links'] = page['links']
    map_hash['assets'] = page['assets']
    site_map << map_hash
    @max_deapth -= 1
    if @max_deapth > 0
      page['links'].each do |link|
        unless site_map.any? {|h| h['url'] == link}
          another_map_hash = {}
          another_map_hash['url'] = link
          site_map << another_map_hash
        end
      end
    end
  rescue OpenURI::HTTPError
    logger.warn "404: #{url}"
    Page.create(url: uri.to_s, links: [], assets: [], "404" => true)
  end

  def parse_page(html)
    doc = Nokogiri::HTML(html)

    css    = doc.css(%{link[type="text/css"]}).map{|node| node["href"]}.compact
    js     = doc.css(%{script}               ).map{|node| node["src"] }.compact
    images = doc.css(%{img}                  ).map{|node| node["src"] }.compact
    links  = doc.css(%{a}                    ).map{|node| node["href"]}.compact.map{|l|
      parse_url(l)
    }.compact.map(&:to_s).uniq.sort

    assets = (css + js + images).sort

    new_page = {}
    new_page['links'] = links
    new_page['assets'] = assets
    new_page
  end

  def parse_url(url)
    uri = @uri.merge(url)
    return nil if uri.host != @uri.host
    uri
  rescue URI::InvalidURIError
    logger.warn "Invalid URL: #{url}"
    return nil
  end
end

# def crawl_domain(url, page_limit = 100) 
#   return if @already_visited.size == page_limit 
#   url_object = open_url(url) 
#   return if url_object == nil 
#   parsed_url = parse_url(url_object) 
#   return if parsed_url == nil 
#   @already_visited[url]=true 
#   if @already_visited[url] == nil 
#     page_urls = find_urls_on_page(parsed_url, url) 
#     page_urls.each do |page_url| 
#       if urls_on_same_domain?(url, page_url) and @already_visited[page_url] == nil 
#         crawl_domain(page_url) 
#       end
#     end
#   end
# end