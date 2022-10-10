class Apmq
  include Logging

  def initialize
    @connection = Bunny.new('amqps://opensuse:opensuse@rabbit.opensuse.org')
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.topic('pubsub', auto_delete: false, passive: true, durable: true)
    @openqa = Openqa.new
    @obs = Obs.new
  end

  def broker
    logger.info('Starting to fish for events...')

    # Trigger openQA if OBS:Server:Unstable images are published
    @channel.queue('', exclusive: true).bind(@exchange, routing_key: 'opensuse.obs.repo.publish_state').subscribe do |_delivery_info, _metadata, payload|
      payload = JSON.parse(payload)

      payload['obs_version'] = 'Unstable' if payload['project'] == 'OBS:Server:Unstable'
      payload['obs_version'] = '2.10' if payload['project'] == 'OBS:Server:2.10:Staging'

      @openqa.trigger(version: payload['obs_version']) if osu_images?(payload: payload)
    end

    # Notify people about openQA builds
    @channel.queue('', exclusive: true).bind(@exchange, routing_key: 'opensuse.openqa.job.done').subscribe do |_delivery_info, _metadata, payload|
      payload = JSON.parse(payload)

      if payload['TEST'] == 'obs_appliance'
        @openqa.set_job(id: payload['id'])
        @openqa.notify
      end
    end

    # Notify people about failed OBS:Server:Unstable / obs-server builds
    @channel.queue('', exclusive: true).bind(@exchange, routing_key: 'opensuse.obs.package.build_fail').subscribe do |_delivery_info, _metadata, payload|
      payload = JSON.parse(payload)
      @obs.notify(status: :failed) if osu_package?(payload: payload)
    end

    # Notify people about successful OBS:Server:Unstable / obs-server builds
    @channel.queue('', exclusive: true).bind(@exchange, routing_key: 'opensuse.obs.package.build_success').subscribe do |_delivery_info, _metadata, payload|
      payload = JSON.parse(payload)
      @obs.notify(status: :success) if osu_package?(payload: payload)
    end

    # Debug...
    # @channel.queue('', exclusive: true).bind(@exchange, routing_key: '#').subscribe do |_delivery_info, _metadata, payload|
    #  logger.debug(payload.to_s)
    # end

    # TODO: implement more...
    # - opensuse.obs.package.service_fail
    # - opensuse.obs.package.create
    # - opensuse.obs.package.package.delete / package.undelete
    # - package.commit
  end

  private

  def osu_images?(payload:)
    return false unless payload['obs_version']

    payload['repo'] == 'images' &&
      payload['state'] == 'published'
  end

  def osu_package?(payload:)
    return false if payload['project'] != 'OBS:Server:Unstable'

    payload['package'] == 'obs-server' &&
      payload['repository'] == '15.4' &&
      payload['arch'] == 'x86_64'
  end
end
