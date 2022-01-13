password=$1
startLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Starting] $log_message"
}
finishLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Completed] $log_message"
}
startLog "Password is $password"
startLog "Updating System"
sudo apt-get update -y
finishLog "Updating System"

startLog "Creating User and Changing User"
sudo useradd pzserver -p $password -m
sudo su pzserver
finishLog "Creating User and Changing User"

startLog "Download linuxgsm.sh"
wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh pzserver
finishLog "Download linuxgsm.sh"

./pzserver install