module SocialNetworks
  extend ActiveSupport::Concern

  def retrieve_photos
    
    return false if provider.blank? || access_token.blank?
    
    normalized_photos = []
    
    if provider=='instagram'
      
      if client = Instagram.client(:access_token => access_token)
        client.user_recent_media(count: 30).each do |photo|
          normalized_photos << {
            id:             photo.id,
            text:           (photo.caption ? photo.caption.text : ""),
            low:            photo.images.low_resolution.url,
            standard:       photo.images.standard_resolution.url,
            thumbnail:      photo.images.thumbnail.url,
            size_low:       [ 306, 306 ],
            size_standard:  [ 640, 640 ],
            size_thumbnail: [ 150, 150 ]
          }
        end
      end

    elsif provider=='facebook'
      
      graph = Koala::Facebook::API.new(access_token)

      graph.get_connections("me","photos/uploaded").each_with_index do |photo,i|
        normalized_photos << {
          id:   photo['id'],
          text: [ (photo['message'] || nil),
                  (photo['from']  ? "From #{photo['from']['name']}" : nil), 
                  (photo['place'] ? "At #{photo['place']['name']}"  : nil) ].
                  compact.join("\n"),
          low:            photo['images'][1] ? photo['images'][1]['source'] : photo['images'][0]['source'],
          standard:       photo['images'][0]['source'],
          thumbnail:      photo['images'][2] ? photo['images'][2]['source'] : photo['images'][0]['source'],
          size_low:       photo['images'][1] ? [ photo['images'][1]['width'], photo['images'][1]['height'] ] : [ photo['width'], photo['height'] ],
          size_standard:  [ photo['width'], photo['height'] ],
          size_thumbnail: photo['images'][2] ? [ photo['images'][2]['width'], photo['images'][2]['height'] ] : [ photo['width'], photo['height'] ]
        }
      end
    end
    
    normalized_photos

  end
end