## Installation

```bash
brew install docker-machine
brew cask install

docker-machine create --driver virtualbox faze

# Run the following command and copy it's output and paste it into your ~/.bash_profile (on osx) or ~/.bashrc (on ubuntu) and remove the # hash marks to uncomment the exports and eval lines.
docker-machine env faze
# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.102:2376"
# export DOCKER_CERT_PATH="/Users/Joshua/.docker/machine/machines/faze"
# export DOCKER_MACHINE_NAME="faze"
# Run this command to configure your shell: (don't uncomment this line)
# eval "$(docker-machine env faze)"

# COPY the above output to your ~/.bash_profile (on osx) or ~/.bashrc (on ubuntu)
nano ~/.bash_profile #or nano ~/.bashrc (on ubuntu)

#paste it into this file at the bottom
```

The result of the end of your `~/.bash_profile` or `~/.bashrc` should look similar to below except for the IP and port.

```bash
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="$HOME/.docker/machine/machines/faze"
export DOCKER_MACHINE_NAME="faze"
# Run this command to configure your shell:
eval "$(docker-machine env faze)"
```

For good measure, restart your terminal.

Now we need to add the selenium hub docker container.
```bash
docker run -d -p 4444:4444 --name selenium-hub selenium/hub:2.47.1
```
This starts a daemonized VM inside your docker VM.  It is a selenium hub.
On it's own, it cannot run tests or browsers.
We need to add Selenium Nodes.

Use foreman to start the test nodes, and to stop use `CTRL+C`
```bash
cd ~/Projects/faze-selenium-tests
foreman start
```

This starts them and registers them with the hub server.
