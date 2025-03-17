# Docker Wordpress + NGINX

Spin up a multi-site dockerized Wordpress host, with routing/proxying via jwilder's nginx-proxy container. Clone the repo, run the initialization script, edit docker-compose.yml and .env files, and a multi-site Wordpress host with NGINX and Cloudflare can be spun up (See Instructions below).

This compose project is meant to be run behind Cloudflare for SSL. I haven't (and am not sure I will) added Letsencrypt support to the nginx-proxy container, and am instead relying on Cloudflare to provide SSL with the "Full" SSL option.

## Why is this useful?

I made this for my personal use, mostly to learn Docker and to play around with Wordpress sites and NGINX.

However, I can see a clear and useful implementation of this container as an "environment creator." If you have a live site, you could easily spin up a 2nd Wordpress instance as a "staging" or "development" version of the live site. You could use a Wordpress migration plugin to create a copy of the live site and make changes/test things in the subdomain, without affecting the primary.

## Requirements

* A docker host with docker-compose set up
* A docker network for the proxy
  * The project expects a network named "proxy_net" by default
  * If you use a different proxy network name, make sure to update the nginx-proxy/docker-compose.yml file and each individual container's docker-compose.yml with the correct proxy network name
* A domain pointed at Cloudflare (if you want SSL)
  * Follow "Cloudflare SSL Setup" instructions below, or the guide in the `inital-setup.sh` script.
* CNAME records for each subdomain you spin up
  * I.e. if you create a new Wordpress instance called "test-blog," you will need a CNAME record for "test-blog.example.com" in Cloudflare

## Instructions

1. Clone repository to docker host
2. Run scripts/initial-setup.sh
    * This script copies the repository to host's docker directory and removes all git stuff (.git dir, .gitignore, the README file, etc), and copies .env.example to .env
3. Open the copied wordpress_nginx directory and edit the docker-compose.yml and .env files
4. In the copied wordpress_nginx/scripts directory, run the `run_full_stack.sh` script
    * When adding new Wordpress instances with the `create_wp_instance.sh` script, you only need to run the `run_new_sites.sh` script, not the "full stack" relaunch script.

## Cloudflare SSL Setup

1. Get an API key and your ZONE ID
    * Search for instructions on creating an API DNS ZONE key with Cloudflare.
    * The ZONE ID can be found on the "Overview" page of a Cloudflare protected site.
2. Once you've created an API key, fill the variables in nginx-proxy's .env file.
    * `PROXY_CF_TOKEN` is your API key, which you created from whatever guide you found.
    * `PROXY_CF_DOMAIN#_ZONE_ID` is the ZONE ID you can find on the site's Overview page
3. Navigate to your domain on Cloudflare.
4. Navigate to site's SSL/TLS tab > Origin Server and create a certificate.
    * Use a wildcard domain, like '*.example.com' for the cert.
    * Save the PEM cert and key file to nginx-proxy/conf/certs/example.com.key and example.com.pem files.
        * These files do not exist, you must create them.
        * Use your domain name, not 'example.com.{key,pem}'
5. On the SSL/TLS Overview tab, set encryption mode to 'Full (strict)'
6. That's all!

## Project structure/explanation

* example_wordpress/
  * This directory gets copied to wordpress_sites/ each time the `create_wp_instance.sh` script is run
    * The `create_wp_instance.sh` script takes an argument for the new instance's name (or prompts for it if no arg is passed), copies the example_wordpress directory, and prepares the .env
    * After the example_wordpress directory is copied, you need to edit the docker-compose.yml and .env files in the wordpress_sites/<copied_wp_example> before running the new site
* nginx-proxy/
  * Hold the docker-compose.yml file for the proxy container. You don't need to mess with this compose file, unless you want a different proxy docker network (default is "proxy_net")
* scripts/
  * Hold scripts for the project/environment
    * `create_wp_instance.sh`
      * Run each time you want to spin up a new Wordpress subdomain/site
    * `initial-setup.sh`
      * The first time you clone the project, run this to copy the repository to its own project subdirectory in your docker/ directory
        * Don't just run docker-compose up -d when you clone the repository. Run this initial setup script first
      * I want this to eventually be the "first stop," where you provide the site's domain name, the proxy network name, etc, and it builds the whole environment for you, but it's not there yet
    * `run_full_stack.sh`
      * Meant to be run after initial-setup.sh
      * Only really needs to be re-run if you rebuild the nginx-proxy container, or have not run that container yet
    * `run_new_sites.sh`
      * When a new site is created, this script loops through the wordpress_sites subdirectories (where the individual Wordpress instances reside) and runs each instance's docker-compose.yml file
      * You run this each time you create a new site
      * I eventually want it to be part of the automated setup, but this project is in the early stages still
* wordpress_sites/
  * When Wordpress instances are created, they're stored in the wordpress_sites/ directory
  * Each time you run the `create_wp_instance.sh` script, a new site will be created in this directory.
  * The `run_new_sites.sh` script loops through wordpress_sites/ and runs each Wordpress instance's docker-compose.yml file, to add it to the running stack
