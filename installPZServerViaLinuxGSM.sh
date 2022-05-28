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

startLog "Updating System"
sudo apt-get install software-properties-common -y
sudo apt-add-repository contrib
sudo apt-add-repository non-free
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get upgrade -y
finishLog "Updating System"

startLog "Installing Packages"
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
sudo apt-get install bc binutils jq lib32gcc1 lib32stdc++6 libsdl2-2.0-0:i386 netcat openjdk-11-jre rng-tools steamcmd tmux unzip -y
finishLog "Installing Packages"

startLog "Creating User and Changing User"
sudo useradd pzserver -p $password -m
sudo chown -R pzserver:pzserver /home/pzserver
finishLog "Creating User and Changing User"

startLog "Download linuxgsm.sh and install server"
sudo -H -u pzserver bash -c "cd ~ && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh pzserver"
sudo -H -u pzserver bash -c "cd ~ && yes | ./pzserver install"
finishLog "Download linuxgsm.sh and install server"

startLog "Config server"
#TODO
finishLog "Config server"

startLog "Start server"
sudo -H -u pzserver bash -c "cd ~ && ./pzserver start"
finishLog "Start server"