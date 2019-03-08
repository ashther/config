function getDockerImage{
    docker image ls
}
Set-Alias dim getDockerImage

function getDockerContainer{
    docker ps -a
}
Set-Alias dps getDockerContainer

function getNetstat{
    netstat -ano |findstr "0.0.0.0"
}
Set-Alias nts getNetstat
