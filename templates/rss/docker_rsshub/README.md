# RSS Hub

RSS feed aggregator, generate feeds from pretty much anything.

## Setup

- Copy [`.env.example`](.env.example) -> `.env`
- Run one of the Compose files:
  - [`compose.yml`](./compose.yml): Uses a browserless container for scraping. Less system resources used, but also less powerful.
    - Run with: `docker compose up -d`
  - [`bundled.compose.yml](./bundled.compose.yml): Bundles a Playwright instance with RSS Hub, which uses more system resources & disk space, but performs better.
    - Run with: `docker compose -f bundled.compose.yml up -d`

## Usage

See the [RSS Hub documentation](https://docs.rsshub.app/guide/) for more info on adding routes. You can also download the [RSSHub Radar Chrome extension](https://chrome.google.com/webstore/detail/rsshub-radar/kefjpfngnndepjbopdmoebkipbgkggaa), or the [Android](https://f-droid.org/en/packages/com.gmail.cn.leetao94.rssaid/)/[iOS](https://apps.apple.com/us/app/rssbud/id1531443645) app.
