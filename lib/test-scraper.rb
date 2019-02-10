require 'open-uri'
require 'nokogiri'
require 'csv'
require 'json'



urls = []
number = 1

2.times do

  url = "https://ramendb.supleks.jp/s/#{number.to_s}.html"
  urls << url
  number += 1
end

def scraper(url)
  file = open(url)
  doc = Nokogiri::HTML(file)
  shop_url = url
  ramen_shops = []
  unless doc.css(".shop-name").text.include?("閉店") || doc.css(".shop-name").text.include?("移転") || doc.css("p.clearfix a img").attribute("src").value.nil?
    shop_name = doc.css(".shop-name").text.strip
    shop_address = doc.at("//span[@itemprop = 'address']").text.strip
    pic_url = doc.css("p.clearfix a img").first.attribute("src").value
    point = doc.css('#shop-status .point div:first-child').text.strip
    # doc.search('p.clearfix a img').each do |el|
    #   puts el.attribute("src").value
    # end

    # shop_address.split(' ')

    ramen_shop = {
      name: shop_name,
      address: shop_address,
      pic: pic_url,
      url: shop_url,
      point: point
    }

    ramen_shops << ramen_shop
  end
  # store(ramen_shops)
end

# def store(data)
#   File.open('sample.json', 'wb') do |file|
#     file.write(JSON.generate(data))
#   end
# end

urls.each do |url|
  scraper(url)
end




