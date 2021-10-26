class Obs
  include Logging

  def initialize
    super
    @trello = Trello.new
    @slack = Slack.new
  end

  def fetch_image(version:)
    binaries = fetch_binaries(version)
    return unless binaries

    image = binaries['binary'].select { |binary| binary['filename'].end_with?('.qcow2') }.last
    if image
      image['build_id'] = "#{image['filename'].gsub('obs-server.x86_64-', '').gsub('Build', '').gsub('.qcow2', '')}"
      image
    else
      logger.fatal('No qcow2 image found...')
    end
  end

  # Sends out notifications for a failed build
  def notify(status:)
    logger.info("Package build #{status}...")

    @trello.status = status
    @trello.notify

    slack_message = 'Build failed for obs-server. https://build.opensuse.org/package/live_build_log/OBS:Server:Unstable/obs-server/15.3/x86_64'
    @slack.notify(message: slack_message) if status == :failed
  end

  private

  def fetch_binaries(version)
    version += ':Staging' unless version == 'Unstable'

    response = Faraday.get("https://api.opensuse.org/public/build/OBS:Server:#{version}/images/x86_64/OBS-Appliance:qcow2")
    unless response.status == 200
      logger.fatal("Could not fetch binaries: #{response.status}")
      return
    end

    Xmlhash.parse(response.body)
  end
end
