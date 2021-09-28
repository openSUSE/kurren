class Slack
  include Logging

  SLACK_URL = ENV.fetch('OBS_TOOLS_SLACK_URL')

  def notify(message:)
    response = Faraday.post(SLACK_URL) do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = { text: message }.to_json
    end
    if response.status == 200
      logger.info('Notified slack...')
    else
      logger.warn("Could not post to slack: #{response.body}")
    end
  end
end
