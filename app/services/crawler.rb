# require 'nokogiri'
# require 'open-uri'
# require 'logger'
# require 'json'
# require 'pry'

class Crawler
  attr_reader :logger, :uri, :site_map, :max_deapth

  def initialize(url)
    @start_url = url    
    @uri = URI.parse(url)
    @site_map = []
    @max_deapth = 2
  end

  def crawl!
    Rails.logger.info "Starting crawl of #{@start_url}"
    crawl_page @start_url
    while page = next_uncrawled_page
      crawl_page page['url']
    end
    site_map.uniq { |e| e['url'] }
  end

  def next_uncrawled_page    
    site_map.detect do |page|
      page['links'].nil?
    end
  end

  def crawl_page(url)
    uri = parse_url(url)
    Rails.logger.info uri.to_s
    page = parse_page(URI.open(uri).read)
    map_hash = site_map.detect { |page| page['url'] == uri.to_s} || {}
    map_hash['url'] = uri.to_s
    map_hash['links'] = page['links']
    map_hash['assets'] = page['assets']
    site_map << map_hash
    @max_deapth -= 1
    if @max_deapth > 0
      page['links'].each do |link|
        another_map_hash = site_map.detect { |page| page['url'] == link} || {}
        another_map_hash['url'] = link
        site_map << another_map_hash
      end
    end
  rescue OpenURI::HTTPError
    Rails.logger.warn "404: #{url}"
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
    Rails.logger.warn "Invalid URL: #{url}"
    return nil
  end
end