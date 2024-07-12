# Labs Portal

![Docker Tracker](https://img.shields.io/docker/pulls/theflightsims/researchlabs)
![GitHub language count](https://img.shields.io/github/languages/count/TheFlightSims/labs-portal)
![GitHub repo size](https://img.shields.io/github/repo-size/TheFlightSims/labs-portal)
![GitHub Repo stars](https://img.shields.io/github/stars/TheFlightSims/labs-portal)

```markdown
This repository is a part of this project: Labs Portal

See the main repo here: https://github.com/TheFlightSims/labs-portal 
```

Provide and free-to-use web-based IDE for campus, team, and enterprise, with unlimited ability.

## Getting started

### With Docker container

Labs Portal on Docker Container helps administrators deploy Labs Portal faster, more securely, and at no additional costs.

For immediate use, try pulling, running, and exporting `80` to your local port

```shell
docker run -p 80:80 theflightsims/researchlabs:latest
```

To save for later, try pulling this image only

```shell
docker pull theflightsims/researchlabs:latest
```

#### Accessing `administrator` account via Labs Portal Web Portal

Once you're done, try to access the web portal. The port is depending on your configuration, by default it is port `80` (with HTTP/No SSL)

Sign up `administrator` account, with your own custom email and password.

![image](https://github.com/TheFlightSims/labs-portal/assets/115929530/f40b2720-847d-40c9-b456-e76081fb93aa)

Once you're done, sign in with your username and password.

### Without Docker container (Recommended)

Labs Portal primarily use all-server, all-infrastructure (IaaS) for widespread deployment, more secure, and easier to maintain, operate, and handle disasters.

For a better understanding of how Labs Portal can handle user data, code handling, and administration, see [CONTRIBUTING GUIDE](https://github.com/TheFlightSims/labs-portal/blob/main/CONTRIBUTING.md).

> Note
>
> We recommend you install local scripts using `root` user only.
>
> DO NOT install it only non-admin users. You won't be able to install PyPI packages, MySQL database for storing user data, as well as administration modules.

#### Cloning & Installing Labs Portal

Labs Portal uses scriptings for fast deployment and removes most unnecessary files and folders that are not related directly to the Labs Portal server operation (e.g. `.wiki`, `wsl-config`, and markdown files).

Cloning from GitHub first

```shell
git clone https://github.com/TheFlightSims/labs-portal.git
```

Installing and Removing local git repo

```shell
cd labs-portal
chmod +x ./master.sh
sudo ./master.sh
```

In the welcome screen, type `2` to start the standard installation. The setup will automatically install and configure your server.

While that, please don't touch on its process. The installation will be completed quickly.

> Note: We recommend you connect to a 50 Mbps or faster Internet connection, so your installation won't be corrupted by Internet speed.

#### Starting Labs Portal

Start the service, using `service` command

```shell
sudo service researchlabs start 
```

Check the status

```shell
sudo service researchlabs status
```

By default, Labs Portal will start at port `443` (with pre-installed SSL) on your local machine.

#### Accessing `administrator` account via Labs Portal Web Portal

Once you're done, try to access the web portal. The port is depending on your configuration, by default it is port `443` (with HTTPS/SSL)

Sign up `administrator` account, with your own custom email and password.

![image](https://github.com/TheFlightSims/labs-portal/assets/115929530/f40b2720-847d-40c9-b456-e76081fb93aa)

Once you're done, sign in with your username and password.

## Contributing

To contribute to this project, you can see different ways in [CONTRIBUTING GUIDE](https://github.com/TheFlightSims/labs-portal/blob/main/CONTRIBUTING.md).

## License

This repo uses [GNU GPL-3.0](https://github.com/TheFlightSims/labs-portal/blob/main/LICENSE) for easier distribution, modification, and installation on any device, with no fee, or additional law barrier.

## Feedback

To feedback this repository, go to [Issues](https://github.com/TheFlightSims/labs-portal/blob/main/issues)
