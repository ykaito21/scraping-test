require 'json'

filepath = '6_data.json'

serialized_restaurants = File.read(filepath)

restaurants = JSON.parse(serialized_restaurants)
puts restaurants
