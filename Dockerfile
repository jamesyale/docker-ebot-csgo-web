FROM ubuntu:14.10

ENV homedir /home/ebotv3-web

RUN apt-get update && apt-get -y upgrade && apt-get clean

RUN apt-get -y install curl git php5-cli php5-mysql libapache2-mod-php5 unzip && apt-get clean

RUN mkdir ${homedir} && curl -L https://github.com/deStrO/eBot-CSGO-Web/archive/master.zip >> ${homedir}/master.zip && unzip -d ${homedir} ${homedir}/master.zip && ln -s ${homedir}/eBot-CSGO-Web-master ${homedir}/ebot-csgo-web && cd ${homedir}/ebot-csgo-web && cp config/app_user.yml.default config/app_user.yml

RUN a2enmod rewrite

RUN sed -i 's/192.168.1.1/ebot/g' $homedir/ebot-csgo-web/config/app_user.yml

RUN sed -i 's@#RewriteBase /@RewriteBase /ebot-csgo@g' $homedir/ebot-csgo-web/web/.htaccess

COPY ebotv3.conf /etc/apache2/conf-enabled/ebotv3.conf

WORKDIR $homedir/ebot-csgo-web

CMD ["sh", "-c", "sleep 10 ; /usr/bin/php symfony configure:database 'mysql:host=mysql;dbname=ebotv3' ebotv3 ebotv3 ; php symfony doctrine:insert-sql; php symfony guard:create-user --is-super-admin admin@ebot admin password ; php symfony cc ; apachectl -d /etc/apache2 -f /etc/apache2/apache2.conf -e debug -DFOREGROUND"]
