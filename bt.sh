cat > /etc/bluetooth/pin.conf << "EOF1"
*  123456
EOF1

cat > /etc/systemd/network/pan0.netdev << "EOF2"
[NetDev]
Name=pan0
Kind=bridge
EOF2

cat > /etc/systemd/network/pan0.network << "EOF3"
[Match]
Name=pan0

[Network]
Address=172.20.1.1/24
DHCPServer=yes
EOF3


cat > /etc/systemd/system/bt-agent.service << "EOF4"
[Unit]
Description=Bluetooth Auth Agent
After=bluetooth.service
Requires=bluetooth.service

[Service]
Type=simple

ExecStart=/usr/bin/bt-agent -c NoInputNoOutput -p /etc/bluetooth/pin.conf
ExecStartPost=/bin/sleep 1
ExecStartPost=/bin/hciconfig hci0 sspmode 0 piscan
Restart=always
RestartSec=1
[Install]
WantedBy=bluetooth.target
EOF4

cat > /etc/systemd/system/bt-network.service << "EOF5"
[Unit]
Description=Bluetooth NEP PAN
After=pan0.network

[Service]
ExecStart=/usr/bin/bt-network -s nap pan0
Restart=always
RestartSec=1
Type=simple

[Install]
WantedBy=multi-user.target
EOF5

sudo systemctl enable systemd-networkd
sudo systemctl enable bt-agent
sudo systemctl enable bt-network
sudo systemctl start systemd-networkd
sudo systemctl start bt-agent
sudo systemctl start bt-network

