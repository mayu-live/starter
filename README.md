# mayu-live/starter

This is a simple starter kit for [mayu live](https://github.com/mayu-live/framework).

You can find the documentation at [mayu.live/docs](https://mayu.live/docs).

Beware that this is experimental software.

## Get started

### Install dependencies

Make sure you have the latest versions of Ruby and NodeJS.
If you have [asdf](https://asdf-vm.com/) you can install
them by typing:

    asdf install

### Setup the starter kit

Clone and setup

    git clone https://github.com/mayu-live/starter.git my-app
    cd my-app
    bundle install
    rake setup

### Ready to run

To start the development server, run:

    bin/mayu dev

If everything worked, you should be able to visit
[`https://localhost:9292/`](https://localhost:9292/)

## Deploying on fly.io

Create a fly app

    fly apps create

Update `fly.toml` with the name of your created app.

Generate a secret key and set it:

    fly secrets set MAYU_SECRET_KEY=securely-randomly-generated-string

Deploy the app

    fly deploy

## Contributing

Beware that there are bugs and rough edges.

Contributions are welcome!
Please create [issues on github](https://github.com/mayu-live/framework/issues)
or send pull requests if you fix something!
