startLog () {
    log_message = $1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[${date}][Starting] ${log_message}"
}
finishLog () {
    log_message = $1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[${date}][Completed] ${log_message}"
}

startLog "Updating System"
sudo apt-get update
finishLog "Updating System"

startLog "Creating User and Changing User"
sudo adduser pzserver -p $1
sudo su pzserver
finishLog "Creating User and Changing User"

startLog "Download linuxgsm.sh"
wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh pzserver
finishLog "Download linuxgsm.sh"

./pzserver install