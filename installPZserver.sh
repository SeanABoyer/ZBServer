startLog "Updating System"
sudo apt-get update
finishLog "Updating System"

startLog "Adding Non-Free to Source List"
sudo apt-get install software-properties-common -y
sudo apt-add-repository contrib
sudo apt-add-repository non-free
sudo dpkg --add-architecture i386
sudo apt-get update -y
finishLog "Adding Non-Free to Source List"


startLog "Installing SteamCMD"
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
sudo apt install lib32gcc1 steamcmd -y
sudo apt-get upgrade -y
finishLog "Installing SteamCMD"

startLog "Link the steamcmd executeable"
ln -s /usr/games/steamcmd steamcmd
finishLog "Link the steamcmd executeable"

startLog "Installing Project Zomboid"
cd ~
steamcmd +force_install_dir /home/steam/project_zomboid +login anonymous +app_update 380870  +quit
finishLog "Installing Project Zomboid"

startLog "Starting Server"
cd "~/.steam/steamapps/common/Project Zomboid Dedicated Server"
./start-server.sh
finishLog "Starting Server"

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