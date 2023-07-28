class Openqa
  include Logging

  attr_accessor :job

  OPENQA_URL = ENV.fetch('OBS_TOOLS_OPENQA_URL', 'https://openqa.opensuse.org')
  OPENQA_API_KEY = ENV.fetch('OBS_TOOLS_OPENQA_KEY')
  OPENQA_API_SECRET = ENV.fetch('OBS_TOOLS_OPENQA_SECRET')
  SMTP_SERVER = ENV.fetch('OBS_TOOLS_SMTP_SERVER')
  GROUP_IDS = { 'Unstable': 62, '2.10': 63, '2.9': 17 }.freeze

  def initialize
    super
    @obs = Obs.new
    @slack = Slack.new
  end

  # Schedule a job for an openQA job group
  def trigger(version:)
    logger.info("OBS published images for #{version}, triggering openQA")
    qcow2_image = @obs.fetch_image(version: version)

    unless qcow2_image
      logger.warn("No image found for #{version}...")
      return
    end

    remaining_jobs = cancel_jobs_but(version: version, image: qcow2_image['filename'])
    if remaining_jobs.any?
      logger.warn("There was a job for #{qcow2_image['filename']} already, skipping...")
      return
    end

    staging_directory = version
    staging_directory += ':/Staging' unless version == 'Unstable'

    iso_url = CGI.escape("https://download.opensuse.org/repositories/OBS:/Server:/#{staging_directory}/images/#{qcow2_image['filename']}")
    iso_path = '/api/v1/isos?DISTRI=obs'
    iso_body = 'ARCH=x86_64&FLAVOR=Appliance'
    iso_body << "&HDD_1_URL=#{iso_url}"
    iso_body << "&VERSION=#{version}"
    iso_body << "&BUILD=#{qcow2_image['build_id']}"
    response = Faraday.post("#{OPENQA_URL}#{iso_path}", iso_body, auth_hash_for_path(path: iso_path))

    if response.status == 200
      logger.info("Scheduled openQA job for #{qcow2_image['filename']}: #{response.body}")
    else
      logger.warn("Could not schedule openQA job: #{response.body}")
    end
  end

  # Sends out notifications for a finished openQA job
  def notify
    return unless job

    logger.info('openQA job done, notifying...')

    notify_mail if job['result'].in?(%w[passed failed])

    return unless ENV.fetch('KURREN_NOTIFY_SLACK_OPENQA', false)

    slack_message = ":fire: openQA failed for #{job['settings']['VERSION']}. "
    slack_message += "See #{OPENQA_URL}/tests/overview?distri=obs&version=#{job['settings']['VERSION']}&build=#{job['settings']['BUILD']}&groupid=#{job['group_id']}"
    @slack.notify(message: slack_message) if job['result'] == 'failed'
  end

  def set_job(id:)
    response = Faraday.get("#{OPENQA_URL}/api/v1/jobs/#{id}")
    unless response.status == 200
      logger.warn("Could not fetch openQA job info: #{response.body}")
      return false
    end

    self.job = JSON.parse(response.body)['job']
  end

  private

  # Cancel all jobs for this version that are unlike the image filename
  def cancel_jobs_but(version:, image:)
    jobs = get_jobs(version: version)
    previous_jobs = jobs.select { |job| job['settings']['HDD_1'] != image }

    logger.debug("Canceling #{previous_jobs.count} previous openQA jobs...") if previous_jobs.any?

    previous_jobs.each do |job|
      path = "/api/v1/jobs/#{job['id']}/cancel"
      response = Faraday.new(url: "#{OPENQA_URL}#{path}", headers: auth_hash_for_path(path: path)).post
      logger.warn("Could not cancel openQA job (#{job['id']}): #{response.body}") if response.status != 200
    end

    jobs - previous_jobs
  end

  def get_jobs(version:)
    group_id = GROUP_IDS[version.to_sym]
    return [] unless group_id

    scheduled = Faraday.get("#{OPENQA_URL}/api/v1/jobs?distri=obs&state=scheduled&group_id=#{group_id}")
    if scheduled.status == 200
      # FIXME: Why does openQA return jobs from other job groups sometimes?
      scheduled = JSON.parse(scheduled.body)['jobs'].delete_if { |job| job['group_id'] != group_id }
    else
      logger.warn("Could not get running openQA jobs: #{scheduled.body}")
      scheduled = []
    end

    running = Faraday.get("#{OPENQA_URL}/api/v1/jobs?distri=obs&state=running&group_id=#{group_id}")
    if running.status == 200
      # FIXME: Why does openQA return jobs from other job groups sometimes?
      running = JSON.parse(running.body)['jobs'].delete_if { |job| job['group_id'] != group_id }
    else
      logger.warn("Could not get running openQA jobs: #{running.body}")
      running = []
    end

    scheduled + running
  end

  def notify_mail
    logger.info('Sending openQA notification mail...')
    message = build_email_message

    begin
      notification = Mail.new(from: 'obs-admin@opensuse.org',
                              to: message['to'],
                              subject: message['subject'],
                              body: message['body'])
      settings = { address: SMTP_SERVER, port: 25, enable_starttls_auto: false }
      settings[:domain] = ENV.fetch('HOSTNAME', 'obs-tools.example.com')
      notification.delivery_method :smtp, settings
      notification.deliver
    rescue StandardError => e
      logger.warn("Could not send mail: #{e.inspect}")
    end
  end

  def build_email_message
    message = {}
    message['to'] = 'obs-tests@opensuse.org'
    emoji = '✔️'

    if job['result'] == 'failed'
      message['to'] = 'obs-errors@opensuse.org'
      emoji = '🔥'
    end

    message['subject'] = "#{emoji} test #{job['result']} on openQA for #{job['group']}"
    message['body'] = <<~MESSAGE_END
      The OBS appliance smoke test #{job['result']} on openQA for

      #{job['settings']['HDD_1_URL']}

      See openQA for details:

      "#{OPENQA_URL}/tests/overview?distri=obs&version=#{job['settings']['VERSION']}&build=#{job['settings']['BUILD']}&groupid=#{job['group_id']}"

    MESSAGE_END

    message
  end

  # returns as hash with openQA HMAC auth headers
  def auth_hash_for_path(path:)
    timestamp = Time.now.to_i
    hmac_hash = OpenSSL::HMAC.hexdigest('sha1', OPENQA_API_SECRET, "#{path}#{timestamp}")
    {
      'X-API-Microtime': timestamp.to_s,
      'X-API-Key': OPENQA_API_KEY,
      'X-API-Hash': "#{hmac_hash}",
      'Accept': 'application/json'
    }
  end
end
