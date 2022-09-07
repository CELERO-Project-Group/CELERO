echo "Stopping containers"
docker stop celerophp-test
docker stop celerodb-test
docker stop celerodbdata-test

echo "Removing containers"
docker rm celerophp-test
docker rm celerodb-test
docker rm celerodbdata-test
