# docker-headless-vnc

This is a workstation hosted inside a docker container that can be reliably built up to a known working state which includes all the tools I use by default.

To start using this image, either use it directly from the docker command line

```bash
docker run -it drjaydenm/docker-headless-vnc
```

or use it as the base of your own image to customize it

```dockerfile
FROM drjaydenm/docker-headless-vnc:latest
```

## Container Setup

All docker commands are available in this repository as VS Code tasks for ease of use whilst editing/updating the image.

### Building

`docker compose build`

### Running

`docker compose up`

The password is stored in the docker-compose.yml file by default, however you can override this at runtime if you like by providing a value for the PASSWORD variable

`PASSWORD=mysupersecurepw docker compose up`

### Bringing it down

`docker compose down`

## Connecting to it

### X11 Forwarding over SSH

From your host machine, run the following command to connect to the container via SSH.

`ssh -Y user@localhost -p 2222`

You should now be able to startup programs from the terminal like some of the examples below

`xeyes`

`xclock`

`firefox`

`sublime`

If you want to startup the full X11 desktop experience over SSH, you can run

`xfce4-session`

### VNC

There is also a VNC server setup and exposed on port 5901 by default. Connect to it by entering `localhost:5901` into your VNC client.

## Getting access to your data

To get access to your host data from the container, you can setup volume mounts in the `docker-compose.yml` file. An example file is in this repository.

## Customizing

TBC

## Credit

Thanks to Daniel Ruiz de Alegría for his amazing work on the Flat Remix GTK theme and icon packs:

* https://drasite.com/
* https://github.com/daniruiz/flat-remix
* https://github.com/daniruiz/flat-remix-gtk