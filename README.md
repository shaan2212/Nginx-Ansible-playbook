# Nginx-Ansible-playbook
1. Create VMs in Azure through terraform (Master-Agent)

2. Install Ansible in Master

- yum install epel-release
- yum install ansible
- yum install python-pip

3. Install Java & Jenkins in Master and change the shell of Jenkins user to /bin/bash

- yum install java-1.8.0-openjdk-devel
- curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
- rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
- yum install jenkins && systemctl start jenkins && systemctl enable jenkins

4. Install Java in Agent

- yum install java-1.8.0-openjdk-devel

5. Create Jenkins user in Agent

6. create passwordless setup between Master(User:root) and Agent(User:root) for ansible. 

7. Create passwordless setup between Master(User:Jenkins) and Agent(User:Jenkins) for Jenkins

8. Add Agent node in Jenkins Master. 

9. Create Nginx deployment Automation in Ansible. 

10. Orchaestrate Ansible-Nginx through Jenkins.
