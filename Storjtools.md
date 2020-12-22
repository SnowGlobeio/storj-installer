<h3>Clean obsolete docker containers</h3>
After several months of operation and updates, docker leaves obsolete stuff behind, taking up space on the system disk.

They can be removed by using the following command:
`docker system prune --all --force --volumes`
