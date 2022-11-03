
echo "** Installing Project dependency, It may take some time. **"
echo "** ======================================  Installing Debian Packages  ====================================== **"
cd apt-get-install
sudo dpkg -i ./*.deb
cd ..

echo "** ======================================  Installing Python  ====================================== **"
sudo ./python/install.sh

echo "** ======================================  Installing pre-gyp  ====================================== **"
sudo npm i -g ./node-pre-gyp
echo "** ======================================  Installing nan  ====================================== **"
sudo npm i -g ./nan
echo "** ======================================  Installing sql-cli  ====================================== **"
sudo npm i -g ./sql-cli

echo "** ======================================  Installing node-gyp  ====================================== **"
# Copy header tarball to offline machine
mkdir -p  ~/.node-gyp/6.10.1
tar -xf ./node-gyp/node-v6.10.1-headers.tar.gz --directory ~/.node-gyp/6.10.1/ --strip-components 1
echo 9 >~/.node-gyp/6.10.1/installVersion
sudo npm i -g ./node-gyp


#!/usr/bin/env bash
echo "** ======================================  Installing Node JS  ====================================== **" &&
sudo cp -r node/{bin,include,lib,share} /usr/ &&
export PATH=/usr/node-v16.18.0-linux-x64/bin:$PATH &&
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node &&
echo "** ======================================  Installing Pm2  ====================================== **" &&
sudo npm i -g ./pm2-master &&

echo "** ======================================  Preparing postgress SQL Depenency  ====================================== **" &&

cd postgresql &&
./configure &&
sudo make &&
echo "** ======================================  Installing postgress SQL Server ====================================== **" &&

sudo su -c  'make install' root && 
echo "** ======================================  Adding user postgres ====================================== **" &&
sudo su -c  'adduser postgres' root && 
sudo su -c 'mkdir /usr/local/pgsql/data' root && 
sudo su -c  'chown postgres /usr/local/pgsql/data' root && 
echo "** ======================================  Finalizing ====================================== **" &&

sudo su -c '/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data' postgres && 
sudo su - postgres -c ' /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start'   && 
sudo su -c '/usr/local/pgsql/bin/createdb test' postgres &&
export PATH="$PATH:/usr/local/pgsql/bin" &&

echo "** Installing redis server **" &&
cd ../redis && 
sudo make &&
sudo make install &&

sudo cp redis.conf /etc/redis &&

sudo cp redis.service  /etc/systemd/system/redis.service &&

echo "** Adding redis user**" &&

sudo adduser --system --group --no-create-home redis ||  echo "** Redis user already exist**" && 

sudo mkdir /var/lib/redis && 
sudo chown redis:redis /var/lib/redis && 

sudo chmod 770 /var/lib/redis && 

sudo systemctl start redis && 

echo "** Installation Finish**" 









DB_NAME=''
DB_USER=''
DB_PASS=''

echo -n "Please specify the database name. (default:revbits): "
read DB_NAME

echo -n "Please specify the superuser name. (default:revbits): "
read DB_USER

echo -n "Please specify the password. (default:revbits): "
read DB_PASS
if [ -z "$DB_NAME" ]; then
  DB_NAME=revbits
fi

if [ -z "$DB_USER" ]; then
  DB_USER=revbits
fi

if [ -z "$DB_PASS" ]; then
  DB_PASS=revbits
fi

sudo su postgres <<EOF
createdb  $DB_NAME;
psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
psql -c "grant all privileges on database $DB_NAME to $DB_USER;"
echo -e "${lightblueb}${1} Postgres User '$DB_USER' and database '$DB_NAME' created.${normal}"
EOF
