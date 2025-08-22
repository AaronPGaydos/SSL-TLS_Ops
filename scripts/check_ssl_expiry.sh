#!/bin/bash
DOMAIN="www.ag-sre-lab.com"
EXPIRY_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null \
  | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_SEC=$(date --date="$EXPIRY_DATE" +%s)
NOW_SEC=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_SEC - $NOW_SEC) / 86400 ))

echo "SSL cert for $DOMAIN expires in $DAYS_LEFT days."
[ "$DAYS_LEFT" -lt 15 ] && echo "Renew soon!" || echo "All good."
