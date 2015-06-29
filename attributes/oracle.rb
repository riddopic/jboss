# encoding: UTF-8
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default[:jboss][:oracle].tap do |oracle|
  #
  # Oracle Database Configuration
  #
  oracle[:enabled] = false

  # A list of filesystem paths or URLs (usually jar files) from where to get
  # the JDBC connector.
  #
  oracle[:resource_url] = []

  # Defines the JDBC driver the datasource should use. It is a symbolic name
  # matching the the name of installed driver. In case the driver is deployed as
  # jar, the name is the name of deployment unit.
  #
  # This is the name of the resource that completes the path:
  #
  # /subsystem=datasources/data-source=#{driver_name}
  #
  oracle[:driver_name] = 'oracle'

  oracle[:jboss_datasource] = 'OracleDS'

  # Oracle driver JDBC Module Name
  #
  oracle[:driver_module] = 'com.oracle.jdbc'

  # Oracle driver Module Dependencies
  #
  oracle[:dependencies] = ['javax.api', 'javax.transaction.api']

  # The fully qualified name of the JDBC datasource class.
  #
  oracle[:driver_class] = 'oracle.jdbc.xa.client.OracleXADataSource'

  # List the JNDI DataSources.
  #
  oracle[:jndi][:datasources] = [
    {
      # Specifies the JNDI name for the datasource.
      #
      jndi_name: 'java:jboss/datasources/OracleDS',

      # The JDBC driver connection URL.
      #
      connection_url: 'jdbc:oracle:thin:@localhost:1521:oraSID',

      # Specify the user name used when creating a new connection.
      #
      db_user: 'db_user',

      # Specifies the password used when creating a new connection.
      #
      db_pass: 'db_pass',

      # The min-pool-size element specifies the minimum number of connections
      # for a pool.
      #
      min_pool_size: 25,

      # The max-pool-size element specifies the maximum number of connections
      # for a pool. No more connections will be created in each sub-pool.
      #
      max_pool_size: 100,

      # The allocation retry element indicates the number of times that
      # allocating a connection should be tried before throwing an exception.
      #
      allocation_retry: 1,

      # The number of prepared statements per connection in an LRU cache.
      #
      statements_cache_size: 32,

      # Should the pool be prefilled. Changing this value can be done only on
      # disabled datasource, requires a server restart otherwise.
      #
      pool_prefill: true,

      # Setting this to false will bind the datasource into global JNDI.
      #
      use_java_context: true,

      # Whether to share prepared statements, i.e. whether asking for same
      # statement twice without closing uses the same underlying prepared
      # statement.
      #
      prepared_statements: true,

      # Specify an SQL statement to check validity of a pool connection. This
      # may be called when managed connection is obtained from the pool.
      #
      check_connection_sql: 'select 1 from dual'
    },
    {
      jndi_name:            'java:jboss/datasources/OracleDS',
      connection_url:       'jdbc:oracle:thin:@localhost:1521:sId',
      db_user:              'db_user',
      db_pass:              'db_pass',
      min_pool_size:         25,
      max_pool_size:         100,
      allocation_retry:      1,
      statements_cache_size: 32,
      pool_prefill:          true,
      use_java_context:      true,
      prepared_statements:   true,
      check_connection_sql: 'select 1 from dual'
    }
  ]
end
