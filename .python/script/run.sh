#!/bin/bash

while true; do
    echo "Starting server..."
    java -Xmx8G -jar server.jar nogui
    echo "Server crashed. Restarting in 5 seconds..."
    sleep 5
done
