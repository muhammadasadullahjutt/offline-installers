sudo dpkg -i ./prepython/*.deb
tar xzf Python-3.9.1.tgz
cd Python-3.9.1
sudo ./configure --enable-optimizations
make -j 2
sudo make alt install
cd ..
