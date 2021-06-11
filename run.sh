# MarketplaceDemo Run.sh

apt-get update
apt-get install zip
unzip db.zip -d /var/

docker stop web
docker stop ubuntu_db_1
docker stop myadmin
docker rm web
docker rm ubuntu_db_1
docker rm myadmin

docker-compose up -d
docker build -t dockernginx .

cd /var/
mkdir mysql_data
mkdir nginx_configuration
rm -rf /var/MarketplaceDemo

git clone https://github.com/alik116/MarketplaceDemo.git
docker run -d -p 80:80 -v /var/MarketplaceDemo:/app --name web dockernginx

docker network create skynet

docker network connect skynet web

docker network connect skynet ubuntu_db_1

docker run --name myadmin -d --link ubuntu_db_1:db -p 8080:80 phpmyadmin

docker network connect skynet myadmin

chmod 0777 -R /var/MarketplaceDemo/views/cache/

cd ~


# docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --name jenkins -d jenkins