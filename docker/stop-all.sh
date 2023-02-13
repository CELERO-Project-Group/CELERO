echo "Stopping containers"
docker stop celerophp
docker stop celerodb
docker stop celerodbdata

echo "Removing containers"
docker rm celerophp
docker rm celerodb
docker rm celerodbdata
