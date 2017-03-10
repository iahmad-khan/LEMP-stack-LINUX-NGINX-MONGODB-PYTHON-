#!/bin/bash
      apt-get update && apt-get -y upgrade
      apt-get install -y haproxy
      echo "ENABLED=1" >> /etc/default/haproxy
      apt-get install -y keepalived
      touch /var/www/check.txt
      echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
      sysctl -p
sleep 1
cat <<EOF > /etc/haproxy/haproxy.cfg
frontend http_front
   bind 192.168.50.100:80
   stats uri /haproxy?stats
   default_backend http_back

backend http_back
   balance leastconn
   option tcp-check
   server node-2.vagrant 192.168.50.11:80 check port 80
   server node-4.vagrant 192.168.50.13:80 check port 80
EOF
sleep 1
cat <<EOF > /etc/keepalived/keepalived.conf 
vrrp_script chk_haproxy {               # Requires keepalived-1.1.13
        script "killall -0 haproxy"     # cheaper than pidof
        interval 2                      # check every 2 seconds
        weight 2                        # add 2 points of prio if OK
}

vrrp_instance VI_1 {
        interface enp0s8
        state MASTER
        virtual_router_id 51
        priority 100                    # 101 on master, 100 on backup
        virtual_ipaddress {
            192.168.50.100
        }
        track_script {
            chk_haproxy
        }
}
EOF
sleep 1
/etc/init.d/keepalived start
sleep 1
/etc/init.d/haproxy start      
