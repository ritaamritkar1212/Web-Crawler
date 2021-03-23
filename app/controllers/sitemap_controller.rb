class SitemapController < ApplicationController
  layout nil
  def index
    crawler = Crawler.new('https://eyescience.com/')
    @sitemap = crawler.crawl!
      
    headers['Content-Type'] = 'application/json'
    render json: @sitemap.to_json
  end
end