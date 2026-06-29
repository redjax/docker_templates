if ( -Not ( Get-Command docker -ErrorAction SilentlyContinue ) ) {
    Write-Error "Docker is not installed"
    exit(1)
}

try {
    docker exec -it rundeck java -jar /home/rundeck/rundeck.war --encryptpwd Jetty
} catch {
    Write-Error "Failed to get secure password"
    exit(1)
}
