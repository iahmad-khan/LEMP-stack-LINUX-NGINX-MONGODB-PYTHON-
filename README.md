**Setup Info:**

**Loader balancer nodes with haproxy and Keepalived:**

    - node-1.vagrant   192.168.50.10         ( Master)

    - node-5.vagrant    192.168.50.14        (Slave)

    - Serving on virtual ip :  192.168.50.100    

Both the nodes are highly available , if master goes down , the slaves will automatically take over virtual ip.


**App servers with Flask app , nginx , unicorn and supervisor**

    - node-2.vagrant     192.166.50.11

    - node-4.vagrant     192.168.50.13

Both the app servers are load balanced by haproxy based on least connections. Also highly available by doing haproxy health checks , if a server goes down , haproxy will not send further requests to it , untill it comes back.


**Mongo DB node:**


    - node-3.vagrant    192.168.50.12


Currently it is just single node , but it can made load balanced and highly available by using more than one node cluster.



**Overall Approach:**

First done by doing manual configuration and testing , then converted to shell scripts that can be run on each node , and finally , shell scripts converted to sensible playbooks.


**Testing:**

    - git clone git@bitbucket.org:iahmad-khan/web-stack-ijaz-ahmad.git

    - cd web-stack-ijaz-ahmad

    - vagrant up


Run the playbooks


    - ansible-playbook backend.yml -i hosts

    - ansible-playbook app_servers.yml -i hosts

    - ansible-playbook haproxy.yml -i hosts


(In case of shh problems: rm -rf ~/.ssh/known_hosts , 
and do ssh ubuntu@host for all hosts and enter yes)


open chrome and Firefox , may be multiple tabs:
and hit the virtual ip:


    192.168.50.100


Now reboot the master load balancer node-1.vagrant down 
and you will still be able to get the page and data from mongoldb. When master reboots , it will take the virtual ip again , but all this process will not be noticed by end user.


Also notice that in different sessions , you will be hitting different app servers , which is load balancing done by Haproxy.


Also check that app servers are highly available by rebooting one of them. haproxy will notice it and will not 
send further requests to it untill it come healthy again.
Note: For now haproxy is checking port 80 for health check , so if the python app which is serving on different port , is down , then haproxy will not know it. Therefore in this case it is checking nginx.


**Tested On:**

  - Darwin Kernel Version 16.0.0: Mon Aug 29 17:56:20 PDT 2016; root:xnu-3789.1.32~3/RELEASE_X86_64 x86_64

  - ansible 2.2.1.0

  - Vagrant 1.9.1

  - Oracle VM VirtualBox web service Version 5.1.16




**Suggested Improvements that can be made:**

- Currently the ip addresses in config files are hard coded , that can be replaced with variables
  so that the enviromenet can auto scale to any number of nodes on any layer ,e.g load balancers , app servers
  and database servers

- Supervisord to be managed to work with systemd so that it can be enabled properly by systemd at system boot

- The backend database layer can be scaled by deploying more than node node with proper configuration,
  currently the backend database layer is a single point of failure. In case of mongodb it is relatively
  easy to scale this layer as compared to RDBMS solutions.

- The keepalived configuration is done to work with two nodes for now, with master has the priorty 101 , and slave with
  priority 100 , it can be configured to have more than one slave nodes.

- Using ansible modules for nginx and haproxy deployment

- Writing a separate ansible module to manage a mongodb cluster with replication and sharding

- OpenStack vagrant provisioner can be used for creating this setup in openstack instead of vbox

- One other alternative approach is to use docker and kubernetes for this whole deployement
