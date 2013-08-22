# Take out

Why cook your server yourself when you can order takeout?

Takeout aims to simplify ruby on rails deployment by wrapping simple ``capistrano`` and ``knife solo`` commands. It uses chef community cookbooks to prep your server. You can now roll your own ubuntu rails server within minutes!

It aims to stay close to to existing tools leveraging cap, chef, knife so and cat.

It's BETA now, please be careful running production, if you really want to. Maybe test it first on local vagrant instances :O

### Features

- Installs RBENV
- Mysql (percona)
- Ruby 2.0 whatevs
- ImageMagick
- Backup

## How to prep a server (only once)

Make sure to have the following prereqs!

- Have an installed Ubuntu 12.04.1 LTS installed virtual machine with IP addressable from the internets.
- Have SSH deamon installed you need to know the root user and the password. obviously.

So, start this puppy by cloning to a local directory, cd'ing and bundle installing.

```
$ git clone git@github.com:emilebosch/takeout.git
$ cd takeout
$ bundle install
```

Initialize a new server (must be 12.04.1 LTS or higher, and make sure you've installed your SSHd). It creates a ``config/server.rb`` file with  your server settings.

```
$ cap takeout:init -s serverip=<ip-address> -s serveruser=<username>
```

Now its time to bootstrap our little box of happiness. This command copies over your ``~/ssh/id.pub`` to the server and installs chef. You will be asked for the root password of your machine (only once cause after we're done its password-less key based autentication adventure time!)

```
$ cap takeout:bootstrap
```

## How to prep for apps (done once per app)

Now you are ready add your apps. This is easily done by creating a config file using our add app command, in this case it creates a `apps/myapp_production.rb`.

```
$ cap takeout:addapp -s appname=<myapp> [-s env=production]
```

You can now edit additional such as sql settings, domain names, etc config in the `./apps` directory.

When you are ready to go, apply the changes to the server, this will update your server using knife solo.

```
$ cap takeout:apply
```

## FAQ

#### OMG FEATURE X IS BROKEN!

You sir, are correct, it's just a BETA right now i'm trying to fine tune everything and gem it up sooner or later but haven't found a sexy flow yet. Suggest an awesome flow or add a pull request.

#### BUT WE HAVE HEROKU/ZURE/OMGPAAS

Yes. But you also have Prism, the PATRIOT act, latency, vendor lock in and no mojo. Real devs prep their servers with `make` and edit with ``cat``.

## Still too much work? Want even more? - Try intercity

[http://intercityup.com](http://intercityup.com)

Made by [traveling-railsman.com](http://traveling-railsman.com)