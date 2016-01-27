#libvirt-tools#

**_A set tools for libvirt_**

## vm_create ##
Create new virtual machine(ubuntu/centos/windows)

	vm_create vm_name template host_name vcpu memory(MB) disk(GB) ip_address netmask gateway dns_server mac_address(optional)

For Example:

	vm_create mysql ubuntu mysql-master 1 512 8 192.168.0.22 255.255.255.0 192.168.0.1 192.168.0.1,8.8.8.8 
	
## vm_clean ##
Destroy VM ,undefine VM's XML, delete VM's image file

	vm_clean vm_name/all --with-images

For Example:
	
	vm_clean mysql --with-images

	
