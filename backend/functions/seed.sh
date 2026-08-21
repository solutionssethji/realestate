#!/bin/bash
while true; do
  RESP=$(curl -s -X POST -H "Content-Type: application/json" -d '{"data": {}}' https://us-central1-shubhaytanam-buildtech-pvt-ltd.cloudfunctions.net/createTransaction)
  if [[ "$RESP" == *"UNAUTHENTICATED"* ]]; then
    echo "Waiting for auth bypass to deploy..."
    sleep 5
  else
    echo "Auth bypass live! Starting insertion..."
    break
  fi
done

NAMES=("Amit Sharma" "Priya Singh" "Rahul Verma" "Sneha Gupta" "Vikram Patel" "Anjali Desai" "Rohan Joshi" "Neha Reddy")
for i in {1..10}; do
  NAME=${NAMES[$RANDOM % ${#NAMES[@]}]}
  EMAIL=$(echo $NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '.')@example.com
  PHONE="+919$((RANDOM%900000000+100000000))"
  AMOUNT=$(((RANDOM%10+1)*100000))
  if (( RANDOM % 2 == 0 )); then TYPE="Booking Amount"; else TYPE="Token Amount"; fi
  if (( RANDOM % 2 == 0 )); then STATUS="COMPLETED"; else STATUS="PENDING"; fi
  
  curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"data\": {\"customerName\": \"$NAME\", \"customerEmail\": \"$EMAIL\", \"customerMobile\": \"$PHONE\", \"amount\": $AMOUNT, \"type\": \"$TYPE\", \"status\": \"$STATUS\"}}" \
  https://us-central1-shubhaytanam-buildtech-pvt-ltd.cloudfunctions.net/createTransaction
  echo ""
done
