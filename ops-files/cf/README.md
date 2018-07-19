# Ops files for Cloud Foundry deployment

You can customize the Cloud Foundry deployment environment. For example, allocate more or less RAM, add routes, provide environment variables to the `java_buildpack`, and more.

Create an `operators/cf/` folder and any `.yml` files in it will be automatically applied to the `cf push -f manifest.yml` during `u up`.

This folder contains production-ready operator files and examples.

For example, to have an explicit route for the `UAA_URL`, copy the `2-explicit-uaa-route.yml` file into `operators/cf/` folder, and run `u up` to apply changes.

```plain
mkdir -p operators/cf/
cp ops-files/cf/2-explicit-uaa-route.yml operators/cf/
u up
```

Some operator files will require additional `vars.yml` variables. Manually edit your `vars.yml` file and add your own values.

Test that your operator files will correctly apply to the base `src/manifest.yml` and other operators using the `u cfyml` command.

```plain
u cfyml
```

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| **Routes** | | |
| [`2-explicit-uaa-route.yml`](2-explicit-uaa-route.yml) | Explicit route for UAA-specific traffic | Perhaps it looks nice to have an https://login.mycompany.com route for users, and https://uaa.mycompany.com for applications |
