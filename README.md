# PoC for cisco ISE Posture Enforcement on RHEL 7

## About this repository

This repository contains a very rudimentary proof-of-concept implementation of a supplicant that checks the firewall (**Firewalld**) and Mandatory Access Control (**SELinux**) subsystems of Red Hat Enterprise Linux, and injects a **custom DHCP Vendor-Class-Identifier** (**cisco-ise-compliant**/**cisco-ise-notcompliant**) into the interface configuration file, **consumed by NetworkManager** for DHCP Client.

## Restrictions of use

The script was tested on Fedora Workstation 25 x86-64 and Red Hat Enterprise Linux (RHEL) 7.3 x86-64, but not exhaustively. **This script is not intended to be used in production, and will not be supported by Red Hat.**

## How to setup

To configure the host to use this script, please follow these steps as root:

1. Download this repository as a ZIP file:

```
# wget https://github.com/davivcgarcia/cisco-ise-rhel7/archive/master.zip -O ~/cisco-ise-rhel7-master.zip
```

2. Unzip the package into the directory '/opt/':

```
# unzip /opt/cisco-ise-rhel7-master.zip
```

3. Make sure the 'cisco-ise-rhel7-verifier.sh' has execution permission:

```
# chmod +x /opt/cisco-ise-rhel7-master/cisco-ise-rhel7-verifier.sh
```

4. Modify the INTERFACE parameter to the IP interface of your host (that will request DHCP);

```
# sed -i 's/INTERFACE=.*/INTERFACE=enp5s0/g' /opt/cisco-ise-rhel7-master/cisco-ise-rhel7-verifier.sh
```

5. Add an entry to root's crontab to run the supplicant every 30 minutes:

```
# crontab -
*/30 * * * * /opt/cisco-ise-rhel7-master/cisco-ise-rhel7-verifier.sh &> /opt/cisco-ise-rhel7-master/cron.log
<CTRL+D>
```
