#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <message_size>"
    exit 1
fi

message_size=$1

sentences=(
    "User login successful."
    "Failed to connect to the database."
    "Order processed and shipped to the customer."
    "Payment received for invoice #12345."
    "Server error: Unable to retrieve data."
    "New user registered with email john.doe@example.com."
    "Password reset request submitted."
    "Email confirmation sent to the user."
    "User account suspended due to suspicious activity."
    "Item added to cart."
    "Item removed from cart."
    "Checkout completed with order ID 98765."
    "Inventory updated for product ID 5678."
    "Shipment tracking number assigned."
    "Customer support ticket created."
    "User profile updated successfully."
    "Discount code applied to the order."
    "Subscription renewed for another year."
    "Scheduled maintenance notification sent."
    "API request rate limit exceeded."
    "Product review submitted by user."
    "Invoice generated for order #6789."
    "User logged out from the system."
    "Two-factor authentication enabled."
    "Account verification completed."
)

while true; do
    uuid=$(uuidgen)
    event_type=$(shuf -e "accept" "reject" "complete" -n 1)

    message=""
    while [ ${#message} -lt $message_size ]; do
        sentence=$(shuf -n 1 -e "${sentences[@]}")
        message="$message $sentence"
        message=$(echo $message | head -c $message_size) 
    done
    
    timestamp=$(date +%s)
    echo "{\"event_id\": \"$uuid\", \"event_type\": \"$event_type\", \"message\": \"$message\", \"timestamp\": $timestamp}" >> output.json

# while true; do
#     uuid=$(uuidgen)
#     event_type=$(shuf -e "accept" "reject" "complete" -n 1)
#     message=$(openssl rand -base64 $((message_size * 3/4)) | tr -dc 'a-zA-Z0-9' | head -c $message_size)
#     timestamp=$(date +%s)
#     echo "{\"event_id\": \"$uuid\", \"event_type\": \"$event_type\", \"message\": \"$message\", \"timestamp\": $timestamp}" >> output.json

  # Check file size and create new file if necessary
    file_size=$(stat -f %z output.json 2>/dev/null)
    if [ $file_size -ge 10485760 ]; then
        mv output.json "$(date +%Y%m%d%H%M%S).json"
        touch output.json
    fi
done