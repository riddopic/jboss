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

default[:jboss].tap do |jboss|
  #
  # The version of JBoss to install. This can be a specific package version
  # (zip or tar.gz), or the version of the war file to download from the JBoss
  # mirror.
  #
  jboss[:version] = nil

  # The mirror to download the JBoss package or war file. Note: You can not
  # download directly from the JBoss site, you will need to provide a location
  # where the file can be downloaded from.
  #
  jboss[:url] = nil

  # The SHA-256 checksum of the JBoss package or war file. This is use to
  # verify that the remote file has not been tampered with. If you leave this
  # attribute set to +nil+, no validation will be performed. If this attribute
  # is set to the wrong MD5 checksum, the Chef Client run will fail.
  #
  jboss[:checksum] = nil

  # The username of the user who will own and run the JBoss process. You can
  # change this to any user on the system. Chef will automatically create the
  # user if it does not exist.
  #
  jboss[:user] = 'jboss'

  # The group under which JBoss is running. JBoss doesn't actually use or
  # honor this attribute - it is used for file permission purposes.
  #
  jboss[:group] = 'jboss'

  # The JBoss user and group will be created as `system` accounts. The default
  # of `true` will ensure that **new** JBoss user accounts are created in the
  # system ID range, exisitng users will not be modified.
  #
  jboss[:system_account] = true

  # The path to the JBoss install location. This will also become the value of
  # +$JBOSS_HOME+. By default, this is the directory where JBoss stores its
  # configuration and build artifacts. You should ensure this directory resides
  # on a volume with adequate disk space.
  #
  jboss[:home] = '/opt/jboss'

  # The directory where JBoss should write its log file(s). The log directory
  # will be owned by the same user and group as the home directory. If you need
  # further customization, you should override these values in your wrapper
  # cookbook.
  #
  jboss[:log][:dir] = '/var/log/jboss'

  # Enables log rotation for the *.log file in `node[:jboss][:log][:dir]`
  # directory.
  #
  jboss[:log][:rotation] = true

  # Sets the frequency for log file rotation. Valid values are: `daily`,
  # `weekly`, `monthly`, `yearly`.
  #
  jboss[:log][:frequency] = 'weekly'

  # Log files are rotated this many times before being removed or mailed.
  #
  jboss[:log][:rotate] = 6

  # JBoss can be run in two different modes, `standalone` or `domain`. A
  # managed domain allows you to run and manage a multi-server topology.
  # Alternatively, you can run a standalone server instance.
  #
  # It's important to understand that the choice between a managed domain and
  # standalone servers is all about how your servers are managed, not what
  # capabilities they have to service end user requests. This distinction is
  # particularly important when it comes to high availability clusters. It's
  # important to understand that HA functionality is orthogonal to running
  # standalone servers or a managed domain. That is, a group of standalone
  # servers can be configured to form an HA cluster. The domain and standalone
  # modes determine how the servers are managed, not what capabilities they
  # provide.
  #
  # So, which should you chose:
  #
  #   * A single server installation gains nothing from running in a managed
  #     domain, so running a standalone server is a better choice.
  #
  #   * For multi-server production environments, the choice of running a
  #     managed domain versus standalone servers comes down to whether the user
  #     wants to use the centralized management capabilities a managed domain
  #     provides. Some enterprises have developed their own sophisticated
  #     multi-server management capabilities and are comfortable coordinating
  #     changes across a number of independent WildFly 8 instances. For these
  #     enterprises, a multi-server architecture comprised of individual
  #     standalone servers is a good option.
  #
  #   * Running a standalone server is better suited for most development
  #     scenarios. Any individual server configuration that can be achieved in a
  #     managed domain can also be achieved in a standalone server, so even if
  #     the application being developed will eventually run in production on a
  #     managed domain installation, much (probably most) development can be
  #     done using a standalone server.
  #
  #   * Running a managed domain mode can be helpful in some advanced
  #     development scenarios; i.e. those involving interaction between
  #     multiple WildFly 8 instances. Developers may find that setting up
  #     various servers as members of a domain is an efficient way to launch a
  #     multi-server cluster.
  #
  # When using Chef to manage your JBoss installations it is recomended to leave
  # JBoss in `standalone` mode.
  #
  jboss[:mode] = 'standalone'

  # Standalone mode configuration.
  #
  jboss[:standalone_conf] = 'standalone-full.xml'

  # The domain controller server configuration file, this includes the main
  # configuration for all server instances. This file is only required for the
  # domain controller.
  #
  jboss[:dom][:conf] = 'domain.xml'

  # The domain controller (`host-master.xml`) or slave host (`host-slave.xml`)
  # configuration file.
  #
  jboss[:dom][:host_conf] = 'host-master.xml'

  # Enforce configuration (when set to true this will force a redeployment of
  # the configuration, overwriting any local changes).
  #
  jboss[:enforce_config] = false

  # AWS S3_PING Configuration. S3_PING uses Amazon S3 to discover initial
  # members. It's designed specifically for members running on Amazon EC2,
  # where multicast traffic is not allowed and thus MPING will not work. Each
  # instance uploads a small file to an S3 bucket and each instance reads the
  # files out of this bucket to determine the other members.
  #
  # The AWS Access Key. This must be set if using private buckets without
  # pre-signed URLs.
  #
  jboss[:aws][:s3_access_key] = nil

  # The AWS Secret Access Key. This must be set if using private bucket without
  # pre-signed URLs.
  #
  jboss[:aws][:s3_secret_access_key] = nil

  # Name of the S3 bucket to use. Either location or prefix must be provided.
  #
  jboss[:aws][:s3_bucket] = nil

  # The 'management' interface is used for all components and services that are
  # required by the management layer (i.e. the HTTP Management Endpoint).
  # Specify the interface to which a socket based on this configuration should
  # be bound. If not defined, the value of the "default-interface" attribute
  # from the enclosing socket binding group will be used.
  #
  jboss[:mgmt_bind_addr] = '0.0.0.0'

  # A standalone JBoss Application Server process, or a managed domain Domain
  # Controller or slave Host Controller process can be configured to listen for
  # remote management requests using its "native management interface":
  #
  jboss[:native_mgmt_port] = 9999

  # The remote management console HTTP port, used to provide the GWT based
  # administration console and also allows for management operations to be
  # executed using a JSON encoded protocol and a de-typed RPC style API. When
  # running a standalone server the native interface allows for management
  # operations to be executed over a proprietary binary protocol. This is used
  # by the supplied command line interface tool and can also be used by other
  # remote clients that use the jars distributed with JBoss to communicate.
  #
  jboss[:http_mgmt_port] = 9990

  # Secure remote management console HTTPS port, provides SSL encryption to
  # secure the communication with the management console
  #
  jboss[:https_mgmt_port] = 9443

  # The 'public' interface binding is used for any application related network
  # communication (i.e. Web, Messaging, etc). Specify the interface to which a
  # socket based on this configuration should be bound. If not defined, the
  # value of the "default-interface" attribute from the enclosing socket
  # binding group will be used.
  #
  jboss[:pub_bind_addr] = '0.0.0.0'

  # The default port for web (HTTP) applications and clients.
  #
  jboss[:http_port] = 8080

  # The default port for SSL-encrypted connection (HTTPS) applications and
  # clients
  #
  jboss[:https_port] = 8443

  # The hostname or IP address to be used for rewriting <soap:address>. If
  # wsdl-host is set to jbossws.undefined.host, JBoss uses requesters host when
  # rewriting the <soap:address>
  #
  jboss[:wsdl_host] = '0.0.0.0'

  # Apache JServ Protocol used for HTTP clustering and load balancing.
  #
  jboss[:ajp_port] = 8009

  # Port offsets are a numeric offset added to the port values given by the
  # socket binding group for that server. This allows a single server to
  # inherit the socket bindings of the server group that is belongs, with an
  # offset to ensure that it does not clash with the other servers in the
  # group. For instance, if the HTTP port of the socket binding group is 8080,
  # and your server uses a port offset of 100, its HTTP port is 8180
  #
  jboss[:port_binding_offset] = 0

  # Set JBoss to startup in debug mode to connect an IDE debugger to the
  # container.
  #
  jboss[:jpda][:enabled] = false

  # The JPDA port to accepting remote debug connections.
  #
  jboss[:jpda][:port] = 8787

  # The hostname of the SMTP server that is used when the server sends emails.
  #
  jboss[:smtp][:host] = 'localhost'

  # The port to send emails over when communicating with the SMTP server.
  #
  jboss[:smtp][:port] = 25

  # Specify if communication to the SMTP server should use SSL-encrypted.
  #
  jboss[:smtp][:ssl] = false

  # The (optional) username to use to connect to the SMTP server.
  #
  jboss[:smtp][:username] = nil

  # The (optional) password used to connect to the SMTP server.
  #
  jboss[:smtp][:password] = nil

  # The amount of time to wait for the server to startup (seconds).
  #
  jboss[:initd][:startup_wait] = 60

  # The amount of time to wait for the server to shutdown (seconds).
  #
  jboss[:initd][:shutdown_wait] = 60

  # If JAVA_HOME should be hardcoded into init.d configuration, based on the
  # value of `node[:java][:java_home]` attribute.
  #
  jboss[:java][:enforce_java_home] = true

  # The maximum memory allocation pool for a Java Virtual Machine (JVM).
  #
  jboss[:java_opts][:xmx] = '512m'

  # The initial memory allocation pool for a Java Virtual Machine (JVM).
  #
  jboss[:java_opts][:xms] = '64m'

  # Used to set size for Permanent Generation, this is where class files are
  # kept. These are the result of compiled classes and jsp pages.
  #
  jboss[:java_opts][:xx_maxpermsize] = '256m'

  # Disable IPv6 and use IPv4 only sockets.
  #
  jboss[:java_opts][:preferipv4] = true

  # Explicitly tell Java to run in Headless mode.
  #
  jboss[:java_opts][:headless] = true

  # A list of any additional Java options that may be required.
  #
  jboss[:java_opts][:other] = []

  # System properties.
  #
  jboss[:system_properties] = [
    # { name: 'JdbcUrl',      value: 'jdbc:mysql://12.34.56.78:3306/testdb' },
    # { name: 'JdbcUsername', value: 'testuser' },
    # { name: 'JdbcPassword', value: 'testpass' }
  ]

  # User configuration, access control provider (simple, or rbac).
  #
  jboss[:acp] = 'simple'

  # Default user (username: wildfly, password: wildfly).
  #
  jboss[:users][:mgmt] = [
    { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
  ]

  # Add application users to the hash 'app'.
  #
  jboss[:users][:app] = [
    { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
  ]

  # Add application roles.
  #
  jboss[:roles][:app] = [
    { id: 'wildfly', roles: 'role1,role2' }
  ]
end
