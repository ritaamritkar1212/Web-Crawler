require_relative '../test_helper'

class CrawlerTest < Crawler::TestCase
  def setup
    @crawler = Crawler.new("http://localhost:3000/")
  end

  def test_parse_relative_url
    url = @crawler.parse_url("/about_us#anchor?param=test")
    assert_equal "http://localhost:3000/about_us#anchor?param=test", url.to_s
  end
  
  def test_parse_absolute_url
    url = @crawler.parse_url("http://localhost:3000/about_us#anchor?param=false")
    assert_equal "http://localhost:3000/about_us#anchor?param=false", url.to_s
  end

  def test_parse_relative_url_with_anchor
    url = @crawler.parse_url("/about_us#anchor")
    assert_equal "http://localhost:3000/about_us#anchor", url.to_s
  end

  def test_parse_relative_url_with_params
    url = @crawler.parse_url("/about_us?param=false")
    assert_equal "http://localhost:3000/about_us?param=false", url.to_s
  end

  def test_parse_external_url
    url = @crawler.parse_url("http://google.com/about_us#anchor?param=false")
    assert_nil url
  end

  def test_parse_subdomain_url
    url = @crawler.parse_url("http://subdomain.example.com/about_us#anchor?param=false")
    assert_nil url
  end

  def test_parse_invalid_uri
    assert_nil @crawler.parse_url("mailto:rita@example.com?subject=Hello There")
  end
end