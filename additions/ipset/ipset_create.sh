ipset create blacklist_ip hash:ip family inet hashsize 1024 maxelem 65536 timeout 0
ipset create blacklist_net hash:net family inet hashsize 1024 maxelem 65536 timeout 0
ipset create f2b-sshd hash:ip family inet hashsize 1024 maxelem 65536 timeout 0

ipset create blacklist_ip6 hash:ip family inet6 hashsize 1024 maxelem 65536 timeout 0
ipset create blacklist_net6 hash:net family inet6 hashsize 1024 maxelem 65536 timeout 0
ipset create f2b-sshd6 hash:ip family inet6 hashsize 1024 maxelem 65536 timeout 0

