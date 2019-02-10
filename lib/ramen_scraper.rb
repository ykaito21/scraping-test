require 'open-uri'
require 'nokogiri'
require 'json'

yah_key = "dj00aiZpPTVqNVd4SlZyNkdVbiZzPWNvbnN1bWVyc2VjcmV0Jng9OGI-"

# being key
key = "Ail6QbvATuf-sIPkryxo83jEIiUFFm3Ihw2bg-Bs68LTtmAYOqpFeZvKariISrXI"


urls = []
number = 3701
data = []

2000.times do
  url = "https://ramendb.supleks.jp/s/#{number.to_s}.html"
  urls << url
  number += 1
end

# urls = ["https://ramendb.supleks.jp/s/17.html"]

urls.each do |url|
  begin
    file = open(url)
    doc = Nokogiri::HTML(file)
    shop_url = url
    sleep(5)

    unless doc.css(".shop-name").text.include?("閉店") || doc.css(".shop-name").text.include?("移転") || doc.css("#review-pickup-box div:nth-child(1) p.clearfix a img").empty?

      shop_name = doc.css(".shop-name").text.strip
      shop_address = doc.at("//span[@itemprop = 'address']").text.strip
      points = doc.css('#shop-status .point div:first-child').text.strip
      open_info = doc.css("#data-table td")[3].text.strip
      close_info = doc.css("#data-table td")[4].text.strip

      pic_data = doc.search('p.clearfix a img').map do |el|
                  el.attribute("src").value
                end
      pic_text = pic_data.join(',')


  # yahoo version
      base_url = 'https://map.yahooapis.jp/geocode/V1/geoCoder'
      params = {
        'appid' => yah_key,
        'query' => shop_address,
        'results' => '1',
        'output' => 'json'
      }
      yah_url = base_url + '?' + URI.encode_www_form(params)
      puts yah_url

      yah_res = JSON.parse(open(yah_url).read)
      puts yah_res
      if yah_res['ResultInfo']['Count'] == 0

        # bing version
          query = URI.encode(shop_address)
          json = "https://dev.virtualearth.net/REST/v1/Locations?q=#{query}&culture=ja&key=#{key}"
          puts json
          res = JSON.parse(open(json).read)
          puts res

          if res["resourceSets"].empty?
            yah_lon = nil
            yah_lat = nil
            yah_address = shop_address + ' ERROR'
          else
            # formatted_address = res["resourceSets"][0]["resources"][0]["address"]['formattedAddress']
            lat = res["resourceSets"][0]["resources"][0]["geocodePoints"][0]["coordinates"][0]
            lon = res["resourceSets"][0]["resources"][0]["geocodePoints"][0]["coordinates"][1]
            yah_address = shop_address + ' ERROR_yahoo'
            yah_lon = lon
            yah_lat = lat
          end
      else
        yah_lon, yah_lat = yah_res['Feature'][0]['Geometry']['Coordinates'].split(',')
        yah_address = yah_res['Feature'][0]['Property']['Address']
      end


      ramen_shop = {
      name: shop_name,
      address: yah_address,
      pics: pic_text,
      link: shop_url,
      points: points,
      latitude: yah_lat,
      longitude: yah_lon,
      open: open_info,
      close: close_info
      }

    data.push(ramen_shop)
    end
    puts shop_url
  rescue NoMethodError => ex
    puts 'no method error'
    puts ex
    puts $@
    puts shop_url
  rescue OpenURI::HTTPError => ex
    puts 'http error'
    puts ex
    puts $@
    puts url
  end
end

json_restaurants = {
  restaurants: data
}
file_name = "#{number}_data.json"
File.open(file_name, 'wb') do |file|
  file.write(JSON.generate(json_restaurants))
end

puts "finish"
