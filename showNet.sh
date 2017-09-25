az network public-ip list --query "[].{DNS:dnsSettings.fqdn,IP:ipAddress}" -o table
