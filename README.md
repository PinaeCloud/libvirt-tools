#libvirt-tools#

**_A set tools for libvirt_**

## create vm ##
Create new virtual machine(ubuntu/centos/windows)

	./create_vm.sh vm_name template host_name vcpu memory(MB) disk(GB) ip_address netmask gateway dns_server mac_address(optional)

For Example:

	./create_vm.sh mysql ubuntu mysql-master 1 512 8 192.168.0.22 255.255.255.0 192.168.0.1 192.168.0.1,8.8.8.8 
	
## clean vm ##
Destroy VM ,undefine VM, delete image file

	./clean_vm.sh vm_name --with-images

For Example:
	
	./clean_vm.sh mysql --with-images

## pcistub.sh ##
Hide or resume device

	./pcistub.sh -h <pcidev> : Hide BDF number of device
	./pcistub.sh -u <pcidev> : Resume BDF number of device
	./pcistub.sh -d <driver> : Driver name

For Example:
	
	lspci # show device 
	./pcistub.sh -h 08:00
	./pcistub.sh -u 08:00 -d e1000
	
