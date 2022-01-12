dtStart = $(date '+%d/%m/%Y %H:%M:%S')
name = "installPZServer"

echo "Starting ${name} at Start: ${dtStart}"
useradd -m steam
cd /home/steam

sudo apt install steamcmd

cd ~
steamcmd +login anonymous +force_install_dir ./project_zomboid +app_update 108600 +quit

dtEnd = $(date '+%d/%m/%Y %H:%M:%S')
echo "Finishing ${name}  at Start: ${dtStart} End: ${dtEnd}"