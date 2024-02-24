#!/bin/bash
# Install prerequisites
apt-get update
apt-get install -y unzip

mkdir /home/admin/.ssh
echo ${authorized_key} >> /home/admin/.ssh/authorized_keys
chmod -r 600 /home/admin/.ssh

# Set up terraria server
useradd -r -md ${terraria_root_dir} terraria

pushd ${terraria_root_dir}
wget wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-${terraria_version}.zip
unzip terraria-server-${terraria_version}.zip
chmod 700 ${terraria_version}/Linux/TerrariaServer.bin.x86_64
mkdir Worlds
aws s3 cp s3://${s3_bucket}/${terraria_config_world_name}.wld Worlds/${terraria_config_world_name}.wld
cat << EOF > ${terraria_version}/Linux/server.config
world=${terraria_root_dir}/Worlds/${terraria_config_world_name}.wld
autocreate=${terraria_config_autocreate}
seed=${terraria_config_seed}
worldname=${terraria_config_world_name}
difficulty=${terraria_config_difficulty}
maxplayers=${terraria_config_maxplayers}
port=${terraria_config_port}
password=${terraria_config_password}
secure=${terraria_config_anticheat}
language=${terraria_config_language}
EOF
chown -R terraria:terraria .
popd

# Set up terraria service and backup service
cat << EOF > /etc/systemd/system/terraria.service
[Unit]
Description=Terraria Server
StartLimitBurst=5
StartLimitIntervalSec=10

[Service]
Type=simple
User=terraria
Restart=always
RestartSec=3
WorkingDirectory=${terraria_root_dir}/${terraria_version}/Linux
ExecStart=${terraria_root_dir}/${terraria_version}/Linux/TerrariaServer.bin.x86_64 -config server.config
ExecStop=/bin/bash -c "echo exit > %t/terraria.stdin && sleep 10 && aws s3 cp /opt/terraria/Worlds/Homestead.wld s3://terraria-world-storage/Homestead.wld"
Sockets=minecraft.socket
StandardInput=socket
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/terraria.socket
[Unit]
PartOf=terraria.service

[Socket]
ListenFIFO=%t/terraria.stdin
EOF

cat << EOF > /etc/systemd/system/terraria-world-backup.service
[Unit]
Description=Terraria World Backup

[Service]
Type=oneshot
WorkingDirectory=${terraria_root_dir}/${terraria_version}/Linux
ExecStart=/bin/bash -c "echo save > %t/terraria.stdin && sleep 10 && aws s3 cp /opt/terraria/Worlds/Homestead.wld s3://terraria-world-storage/Homestead.wld"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable terraria.socket
systemctl enable terraria.service
systemctl start terraria.socket
systemctl start terraria.service
