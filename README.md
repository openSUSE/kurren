![Kurren](https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Greetsiel_Krabbenkutter_Hafen.JPG/320px-Greetsiel_Krabbenkutter_Hafen.JPG)

# Kurren

Fish in the sea of AMQP messages from rabbit.opensuse.org and do the right thing.

- Trigger openQA test runs if OBS:Server:Unstable images are published
- Notify via slack/mail about openQA test runs
- Notify via slack/trello about failed OBS:Server:Unstable builds

## Installation

```shell
zypper install libxml2-devel gcc ruby3.1-devel
bundle install --path vendor/bundle
```

or use [docker-compose](https://docs.docker.com/compose/)

```shell
docker-compose pull
```

## Configuration

This bot is configured via environment variables. Either set them however you set them
or copy the `dotenv.example` file to `.env` and the script picks them up from this file.

## Usage
```shell
bundle exec ruby kurren.rb
```

or use docker-compose

```shell
docker-compose up
```

## Development / Contribution

If you want to contribute please checkout our [contribution readme](CONTRIBUTING.md)
