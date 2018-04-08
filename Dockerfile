FROM php:5.6-apache

ENV homedir /home/ebotv3-web

RUN apt-get update && apt-get -y upgrade && apt-get clean

RUN apt-get -y install curl git && apt-get clean

RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-enable pdo_mysql

RUN mkdir ${homedir} && cd ${homedir} && git clone https://github.com/deStrO/eBot-CSGO-Web.git && ln -s ${homedir}/eBot-CSGO-Web ${homedir}/ebot-csgo-web && cd ${homedir}/ebot-csgo-web && cp config/app_user.yml.default config/app_user.yml

RUN a2enmod rewrite

RUN sed -i 's/192.168.1.1/ebot/g' $homedir/ebot-csgo-web/config/app_user.yml

RUN sed -i 's@#RewriteBase /@RewriteBase /ebot-csgo@g' $homedir/ebot-csgo-web/web/.htaccess

COPY ebotv3.conf /etc/apache2/conf-enabled/ebotv3.conf

COPY wait-for-it.sh /tmp/

WORKDIR $homedir/ebot-csgo-web

CMD ["sh", "-c", "bash /tmp/wait-for-it.sh -h mysql -p 3306 -t 0; php symfony configure:database 'mysql:host=mysql;dbname=ebotv3' ebotv3 ebotv3 ; php symfony doctrine:insert-sql; php symfony guard:create-user --is-super-admin admin@ebot admin password ; php symfony cc ; rm -rf $homedir/ebot-csgo-web/web/installation ; apachectl stop ; apachectl -d /etc/apache2 -f /etc/apache2/apache2.conf -e debug -DFOREGROUND"]
