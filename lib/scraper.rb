require 'open-uri'
require 'nokogiri'
require 'csv'

class Scraper

  def initialize(url)
    @doc = Nokogiri::HTML(open(url))
    @ramen_shops = []
  end

  def scrape_content
    unless @doc.css(".shop-name").text.include?("閉店") || @doc.css(".shop-name").text.include?("移転") || @doc.css("p.clearfix a img").attribute("src").value.nil?
      shop_name = @doc.css(".shop-name").text.strip
      shop_address = @doc.at("//span[@itemprop = 'address']").text.strip
      pic_url = @doc.css("p.clearfix a img").first.attribute("src").value

      ramen_shop = {
        name: shop_name,
        address: shop_address,
        pic: pic_url
      }
    end
  end

  def add_shop(ramen_shop)
    @ramen_shops << ramen_shop
  end

end

class GetUrl

  def initialize
    @urls = []
    @number = 1
  end

  def add_url
    url = "https://ramendb.supleks.jp/s/#{number.to_s}.html"
    @urls << url
    @number += 1
  end
end

url = GetUrl.new

30.times do
  url.add_url
end

puts url_list = url.urls

url_list.each do |list|
  scrape = Scraper.new(list)
  content = scrape.scrape_content
  shops = scrape.add_shop(content)
  puts shops
end

# scrape = Scraper.new("https://ramendb.supleks.jp/s/1.html")
# content = scrape.scrape_content
# shops = scrape.add_shop(content)
# puts shops
