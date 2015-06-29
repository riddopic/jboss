
# JBoss Cookbook

This cookbook install and manages a JBoss Wildfly (>= 7) or EAP (>= 6) application server. It can also configure any resource which can be managed from the Jboss-CLI, including but not limited to:

* subsystems
* data-sources
* security-domains
* system-properties
* thread-pools

## Requirements

Before trying to use the cookbook make sure you have a supported system. If
you are attempting to use the cookbook in a standalone manner to do testing
and development you will need a functioning Chef/Ruby environment, with the
following:

* Chef 11 or higher
* **Ruby 2.0 or higher** (preferably using the ChefDK)

### Chef

Chef Server version 11+ and Chef Client version 11.16.2+ and Ohai 7+ are
required. Clients older that 11.16.2 do not work.

### Platforms

This cookbook uses Test Kitchen to do cross-platform convergence and post-
convergence tests. The tested platforms are considered supported. This
cookbook may work on other platforms or platform versions with or without
modification.

* Ubuntu 14.04
* CentOS 6.6, 7.1

The following platforms are known to work:

- Debian family (Debian, Ubuntu etc)
- Red Hat family (Redhat, CentOS, Oracle etc)
- Fedora family

### Cookbooks

The following cookbooks are required as noted (check the metadata.rb file for
the specific version numbers):

* [Apt](https://supermarket.getchef.com/cookbooks/yum) - Configures apt and
  apt services and LWRPs for managing apt repositories and preferences.
* [Ark](https://supermarket.getchef.com/cookbooks/yum) - Provides a resource for managing software archives.
* [garcon](https://supermarket.getchef.com/cookbooks/yum) - Collection of helper methods.
* [Java](https://supermarket.chef.io/cookbooks/java) - Installs the Java
  runtime.
* [logrotate](https://supermarket.getchef.com/cookbooks/yum) - Installs logrotate package and provides a definition for logrotate configs.
* [Yum](https://supermarket.getchef.com/cookbooks/yum) - Configures various
  yum components on Red Hat-like systems.

## Usage



## Attributes

In order to keep the README managable and in sync with the attributes, this cookbook documents attributes inline. The usage instructions and default values for attributes can be found in the individual attribute files.

## Recipes
* `boss::default` - Installs Java (uses the Java community cookbook) and the JBoss application server. This will also install the Connector/J if it has been enabled.
* `jboss::install` - Installs the JBoss application server.
* `boss::mysql_connector` - Installs the MySQL Connector/J.

## Providers

This cookbook includes resource and providers for managing:

  * `jdbc_driver` for managing JDBC Driver
  * `datasource` for managing non-XA Datasource
  * `db2_xa_datasource` for managing DB2 XA Datasource
  * `h2_xa_datasource` for managing H2 XA Datasource
  * `oracle_xa_datasource` for managing Oracle XA Datasource
  * `mssql_xa_datasource` for managing MSSQL XA Datasource
  * `system_property` for managing the System Properties
  * `ldap_authentication`
  * `ldap_connection`
  * `ldap_security_domain` for managing LDAP Security Domain
  * `ldap_security_realm` for managing LDAP Security Realm
  * `ssl_connector_extension`
  * `web_connector` for managing WEB Connector
  * `vault` For managing VAULT
  * `logger`
  * `log_handler`
  * `management_interface`
  * `management_realm`
  * `mapping_module`
  * `server_identity`
  * `single_ldap_security_domain`
  * `single_mapping_module`

### jdbc_driver

A Resource and provider for managing JDBC drivers.

#### Syntax

The syntax for using the `jdbc_driver` resource in a recipe is as follows:

    jdbc_driver 'name' do
      attribute 'value' # see attributes section below
      ...
      action :action # see actions section below
    end

Where:

  * `jdbc_driver` tells the chef-client to use the
    `Chef::Provider::JBossJDBCDriver` provider during the chef-client run;
  * `name` is the JDBC driver name;
  * `attribute` is zero (or more) of the attributes that are available for this
    resource;
  * `:action` identifies which steps the chef-client will take to bring the
    node into the desired state.

For example:

```
jboss_jdbc_driver 'oracle' do
  driver_module_name              'com.oracle.jdbc'
  driver_class_name               'oracle.jdbc.OracleDriver'
  driver_xa_datasource_class_name 'oracle.jdbc.xa.client.OracleXADataSource'
end
```

#### Actions

  * `:add`: Default. Use to add a new JDBC driver.
  * `:remove`: Use to remove the JDBC driver.

#### Attribute Parameters

  * `name` The JDBC driver name.
  * `driver_module_name` The JDBC driver module name.
  * `driver_module_slot` The JDBC driver module slot.
  * `driver_class_name` isThe JDBC driver class name.
  * `driver_xa_datasource_class_name` The JDBC driver XA datasource alass name.

#### Examples

The following examples demonstrate various approaches for using resources in
recipes. If you want to see examples of how Chef uses resources in recipes, take
a closer look at the cookbooks that Chef authors and maintains: https://
github.com/opscode-cookbooks.

#### JBoss Wildfly AS 7 or EAP 6 with Oracle JDBC driver.

```
jboss_jdbc_driver 'oracle' do
  driver_module_name              'com.oracle.jdbc'
  driver_class_name               'oracle.jdbc.OracleDriver'
  driver_xa_datasource_class_name 'oracle.jdbc.xa.client.OracleXADataSource'
end
```

## License and Authors

```
Author::   Stefano Harding <riddopic@gmail.com>
Copyright: 2014-2015, Stefano Harding

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[Berkshelf]: http://berkshelf.com "Berkshelf"
[Chef]: https://www.getchef.com "Chef"
[ChefDK]: https://www.getchef.com/downloads/chef-dk "Chef Development Kit"
[Chef Documentation]: http://docs.opscode.com "Chef Documentation"
[ChefSpec]: http://chefspec.org "ChefSpec"
[Foodcritic]: http://foodcritic.io "Foodcritic"
[Learn Chef]: http://learn.getchef.com "Learn Chef"
[Test Kitchen]: http://kitchen.ci "Test Kitchen"
[Apt]: https://supermarket.getchef.com/cookbooks/yum "Apt Cookbook"
[Java]: https://supermarket.chef.io/cookbooks/java "Java Cookbook"
[Yum]: https://supermarket.getchef.com/cookbooks/yum "Yum Cookbook"

