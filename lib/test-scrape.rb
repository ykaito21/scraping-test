require 'open-uri'
require 'nokogiri'
require 'csv'

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
  unless doc.css(".shop-name").text.include?("閉店") || doc.css(".shop-name").text.include?("移転") || doc.css("p.clearfix a img").attribute("src").value.nil?
    shop_name = doc.css(".shop-name").text.strip
    open_info = doc.css("#data-table td")[3].text.strip
    close_info = doc.css("#data-table td")[4].text.strip

     ramen_shop = {
        name: shop_name,
        open: open_info,
        close: close_info
      }

      puts ramen_shop

  end
end


urls.each do |url|
  scraper(url)
end
