#/bin/sh
socks_port="1180"
socks_user="jxyt"
socks_pass="jxyt1688"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -x
iptables-save
ips=(
$(hostname -I)
)

# Xray Installation
wget -o /usr/local/bin/xray https://github.com/siemenstutorials/MutiPxray/releases/download/v20221022/xray
chmod +x /usr/local/bin/xray
cat  <<EOF > /etc/systemd/system/xray.service 
[Unit]
Description=Xray Serve
After=network-online.target
[Service]
ExecStart=/usr/local/bin/xray -c /etc/xray/serve.toml
ExecStop=/bin/kill -s QUIT $MAINPID
Restart=always
RestartSec=15s
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xray

#Xray Configuration 
mkdir -p /etc/xray
echo -n "" > /etc/xray/serve.toml
for ((i = 0; i < ${#ips[@]}; i++)); do
cat <<EOF >> /etc/xray/serve.toml 
[[inbounds]]
listen = "${ips[i]}"
port = $socks_port
protocol = "socks"
tag = "$((i+1))"
[inbounds.settings]
auth = "password"
udp = true
ip = "${ips[i]}"
[[inbounds.settings.accounts]]
user = "$socks_user"
pass = "$socks_pass"
[[routing.rules]]
type = "field"
inboundTag = "$((i+1))"
outboundTag = "$((i+1))"
[[outbounds]]
sendThrough = "${ips[i]}"
protocol = "freedom"
tag = "$((i+1))"
EOF 
done
systemctl stop xray
systemctl start xray
systemctl status xray



#firewall-cmd --zone=public --add-port=1180/tcp --permanent
