# mayu-live/starter

This is a simple starter kit for [mayu live](https://github.com/mayu-live/framework).

You can find more documentation at [mayu.live/docs](https://mayu.live/docs).

**Beware that this is experimental software.**

If you have all dependencies installed, you should
be able to deploy the app within a few minutes.

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

Make sure you have installed [flyctl](https://fly.io/docs/flyctl/installing/)
and that you [have an account](https://fly.io/docs/flyctl/auth-signup/) at
[fly.io](https://fly.io/) and that you have
[logged in](https://fly.io/docs/flyctl/auth-login/).

Then, generate a `fly.toml` config file by running the following command:

    rake setup_fly

This will generate an app name for you, and if everything worked,
it will give you the option to deploy immediately.

Otherwise, you can deploy at any time by typing:

    fly deploy

## Contributing

Beware that there are bugs and rough edges.

Contributions are welcome!
Please create [issues on github](https://github.com/mayu-live/framework/issues)
or send pull requests if you fix something!
