require 'open-uri'
require 'nokogiri'
require 'csv'

urls = []
number = 1

30.times do

  url = "https://ramendb.supleks.jp/s/#{number.to_s}.html"
  urls << url
  number += 1
end

puts urls



def scraper(url)
  file = open(url)
  doc = Nokogiri::HTML(file)
  content(doc)
end

def content(doc)
  ramen_shops = []
  unless doc.css(".shop-name").text.include?("閉店") || doc.css(".shop-name").text.include?("移転") || doc.css("p.clearfix a img").attribute("src").value.nil?
    shop_name = doc.css(".shop-name").text.strip
    shop_address = doc.at("//span[@itemprop = 'address']").text.strip
    pic_url = doc.css("p.clearfix a img").first.attribute("src").value

    # shop_address.split(' ')

    ramen_shop = {
      name: shop_name,
      address: shop_address,
      pic: pic_url
    }

    ramen_shops << ramen_shop
  end
  puts ramen_shops
end

urls.each do |url|
  scraper(url)
end


# html_file = open(url).read
# html_doc = Nokogiri::HTML(html_file)

# html_doc.search('#shop-data').each do |element|
#   puts element.text.strip
#   puts element.attribute('href').value
# end
