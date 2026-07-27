# Baikal DAV

[Baikal](https://github.com/sabre-io/Baikal) is a calDAV and cardDAV server with a webUI built atop [SabreDAV](https://sabre.io/). This image uses the [`aalmenar/baikal-docker` image](https://github.com/aalmenar/baikal-docker). It uses the `:nginx` tag by default; you can set `BAIKAL_IMG_TAG` in the [`.env` file](./.env.example) to change the tag.

See all available tags on the [`aalmenar/baikal-docker` Github container registry](https://github.com/aalmenar/baikal-docker/pkgs/container/baikal/versions?filters[version_type]=tagged).

## DAV Setup

On clients (i.e. phone, Thunderbird, etc), use the `/dav.php` route to configure access to a calendar or address book. For example, if your Baikal instance is at `https://baikal.mydomain.com`, to add a calendar for user `user1` you would use the URL `https://baikal.mydomain.com/dav.php/calendar/user1/calendar-id`, and you would authenticate with `user1`'s password.

iPhone has DAV syncing for contacts and calendars built-in. On Android, use the [open-source DAVx5 app](https://www.davx5.com/).
