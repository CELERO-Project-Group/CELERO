#renews the lets encrypt certificate, as pre-hook it stops the celero docker container. After the renew it starts it again.
certbot renew --pre-hook "/usr/local/bin/docker-compose stop"  --post-hook "/usr/local/bin/docker-compose up -d" --dry-run
