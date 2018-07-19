# U - UAA deployment with Cloud Foundry

This project is dedicated to making it easy to bring up a secure, production-ready UAA on any Cloud Foundry, and to upgrade it in future.

This project is derived from UAA's own suggestions for how to run the UAA on Cloud Foundry, and the subcommands and operator files are designed to match the sister project for deploying UAA with BOSH, [uaa-deployment](https://github.com/starkandwayne/uaa-deployment).

The name of the helper application is `u`. This name matches the sister project's helper name. This name in turn came from the project [BUCC](https://github.com/starkandwayne/bucc), with its helper app `bucc`, which stood for BOSH-UAA-CredHub-Concourse. Since this project only deploys the UAA, we appropriately shorten the helper name to `u`.

## Deploy UAA

To bootstrap a secure, production-grade UAA to any Cloud Foundry:

First, clone this repo.

```plain
git https://github.com/starkandwayne/uaa-deployment-cf
cd uaa-deployment-cf
```

If you have `direnv` installed, you will be asked to `direnv allow` and then you will see the dependent CLIs (`cf`, `uaa`, and `bosh`) downloaded into the `bin/` folder.

If you do not see this, instead manually source the `u env` output to preinstall the dependent CLIs into your local path:

```plain
source <(bin/u env)
```

Using the `cf` CLI, target and login to your Cloud Foundry, and select an organization and space:

```plain
cf login -a https://api.run.pivotal.io --sso
cf create-space uaa-production
cf target -s uaa-production
```

Next, create a PostgreSQL or MySQL database called `uaa-db`:

```plain
# PostgreSQL on PWS
cf create-service elephantsql turtle uaa-db

# MySQL on PWS
cf create-service cleardb spark uaa-db
```

To generate secrets, encyption keys, certificates for your UAA, and deploy the UAA to your Cloud Foundry:

```plain
u up --route drnic-uaa-production.cfapps.io
```

Note, the `u up` command can be run in future to upgrade. The flags provided above will be cached in `vars.yml` and not be required to be provided again.

Once deployed, visit the UAA home page for users to login https://drnic-uaa-production.cfapps.io (for your route).

You can see the generated `uaa_admin` client secret, and complimentary `admin` user:

```plain
$ u info
```

To target and authorize the [`uaa` CLI](https://github.com/cloudfoundry-incubator/uaa-cli):

```plain
u auth-client

uaa clients
uaa users
uaa groups
```

To use the `u` and `uaa` CLIs anywhere, source the `u env` output:

```plain
source <(path/to/uaa-deployment-cf/bin/u env)

uaa clients
uaa users
uaa groups
```

## Customize UAA

You can customize your UAA by applying operator files. Create an `operators` folder and any `.yml` files in it will be automatically applied to your UAA YAML configuration.

See the [`ops-files`](ops-files/) folder for more instructions and many production-ready operator files.

## Create Users

For each staff member you can easily create a new UAA user:

```plain
uaa create-user drnic \
  --email drnic@starkandwayne.com \
  --givenName "Dr Nic" \
  --familyName "Williams" \
  --password drnic_secret
```

You can assign them to groups (which gives them access to authorized scopes):

```plain
uaa add-member uaa.admin drnic
```

## Upgrade UAA

To upgrade, pull the lastest commits from the `master` branch and run `u up` again.

```plain
cd path/to/uaa-deployment-cf
git pull
u up
```

## Destroy UAA

To tear down your UAA and its database:

```plain
u down
```