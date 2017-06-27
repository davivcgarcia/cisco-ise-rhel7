#! /bin/bash
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Author: Davi Garcia (davivcgarcia@gmail.com)
#  About: This is a PoC of integration of RHEL 7 with Cisco ISE by DHCP.
#         Custom vendor-class-identifier will inform compliance status.
 
# Parameters that can be customized.
 
DHCP_PREFIX="cisco-ise-"
INTERFACE=enp0s25
DEBUG=true
 
# Determine if the custom DHClient config is already provisioned or
# if it is necessary to create it with the sed marker.
 
if [ ! -x /etc/dhcp/dhclient-$INTERFACE.conf ]; then
	$DEBUG && echo "[$(date)] DHClient config file not found. Created!"
    echo "send vendor-class-identifier '$DHCP_PREFIX'" > /etc/dhcp/dhclient-$INTERFACE.conf
    chmod +x /etc/dhcp/dhclient-$INTERFACE.conf
else
    if [ -z "$(grep $DHCP_PREFIX /etc/dhcp/dhclient-$INTERFACE.conf)" ]; then
        $DEBUG && echo "[$(date)] DHClient config file do not have the default config. Added!"
        echo "send vendor-class-identifier '$DHCP_PREFIX'" > /etc/dhcp/dhclient-$INTERFACE.conf
    fi
fi
 
# Determine the status of SELinux.
 
if [ $(/sbin/getenforce) == "Enforcing" ]; then
    SELINUX=1
    $DEBUG && echo "[$(date)] Checking SELinux: enabled!"
else
    SELINUX=0
    $DEBUG && echo "[$(date)] Checking SELinux: disabled!"
fi
 
# Determine the status of FirewallD.
 
if [ $(/bin/systemctl is-active firewalld) == "active" ]; then
        FIREWALL=1
    $DEBUG && echo "[$(date)] Checking Firewalld: enabled!"
else
    FIREWALL=0
    $DEBUG && echo "[$(date)] Checking Firewalld: disabled!"
fi
 
# Based on status of SELinux and FirewallD, determine the suffix used with DHCP.
 
if [ $SELINUX -eq 1 ] && [ $FIREWALL -eq 1 ]; then
    DHCP_SUFIX="compliant"
    $DEBUG && echo "[$(date)] Status: host is compliant!"
else
    DHCP_SUFIX="notcompliant"
    $DEBUG && echo "[$(date)] Status: host is not compliant!"
fi
 
# Update the DHClient config file with proper DHCP vendor-class-identifier.
$DEBUG && echo "[$(date)] Updating DHClient config file!"
sed -i "s/'$DHCP_PREFIX.*'/'$DHCP_PREFIX$DHCP_SUFIX'/g" /etc/dhcp/dhclient-$INTERFACE.conf
exit 0

