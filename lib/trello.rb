class Trello
  include Logging

  TRELLO_API_KEY = ENV.fetch('OBS_TOOLS_TRELLO_API_KEY')
  TRELLO_API_TOKEN = ENV.fetch('OBS_TOOLS_TRELLO_API_TOKEN')
  TRELLO_CARD_ID = ENV.fetch('OBS_TOOLS_TRELLO_CARD_ID')

  TRELLO_CONTENT_URL = "https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/desc?key=#{TRELLO_API_KEY}&token=#{TRELLO_API_TOKEN}".freeze
  TRELLO_ATTACHMENT_URL = "https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/attachments?key=#{TRELLO_API_KEY}&token=#{TRELLO_API_TOKEN}".freeze

  attr_accessor :status

  def notify
    return unless ENV.fetch('KURREN_NOTIFY_TRELLO_OBS', 'false') == 'true'

    change_card_content
    change_card_cover
  end

  def change_card_content
    trello_card_content = "Last status scan for [OBS:Server:Unstable/obs-server](https://build.opensuse.org/package/show/OBS:Server:Unstable/obs-server) at #{Time.now}:\n\n"
    response = Faraday.put(TRELLO_CONTENT_URL, value: trello_card_content)
    if response.success?
      logger.info('Successfully set trello card content')
    else
      logger.warn("Unable to change card content: #{response.body}")
    end
  end

  def change_card_cover
    cover_id = trello_cover_id
    return unless cover_id

    cover_url = "https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/idAttachmentCover?value=#{cover_id}&key=#{TRELLO_API_KEY}&token=#{TRELLO_API_TOKEN}"
    response = Faraday.put(cover_url)
    if response.success?
      logger.info('Successfully set trello card cover')
    else
      logger.warn("Unable to change card cover: #{response.body}")
    end
  end

  private

  def trello_cover_id
    response = Faraday.get(TRELLO_ATTACHMENT_URL)
    unless response.success?
      logger.warn("Unable to get card, not changing card cover: #{response.body}")
      return
    end

    image_name = status.to_s == 'success' ? 'passed.jpg' : 'failed.jpg'

    attachments = JSON.parse(response.body)
    attachments.select! { |image| image['name'] == image_name }

    return if attachments.empty?

    attachments.first['id']
  end
end
