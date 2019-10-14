# Ansible <!-- this role name --> role

This is an [Ansible](http://www.ansible.com) role which <!-- brief description of the role goes here -->.

## Requirements

<!-- Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required. For example: -->

[Ansible 2.7+](http://docs.ansible.com/ansible/latest/intro_installation.html)

## Role Variables

<!-- A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well. For example: -->

A list of all the default variables for this role is available in `defaults/main.yml`.

The role also setups the following facts:

- `thisrole_fact1`: description of the fact
- `thisrole_fact2`: description of the fact
- `thisrole_factN`: description of the fact

## Filters

<!-- A description of the filters provided by the role should go here. For example: -->

The role provides these filters:

- `thisrole_filter1`: description of the filter
- `thisrole_filter2`: description of the filter
- `thisrole_filterN`: description of the filter

## Modules

<!-- A description of the modules provided by the role should go here. For example: -->

The role provides these modules:

- `thisrole_module1`: description of the module
- `thisrole_module2`: description of the module
- `thisrole_moduleN`: description of the module

## Tests

<!-- A description of the tests provided by the role should go here. For example: -->

The role provides these tests:

- `thisrole_test1`: description of the test
- `thisrole_test2`: description of the test
- `thisrole_testN`: description of the test

## Dependencies

<!-- A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles. For example: -->

- [amtega.check_platform](https://galaxy.ansible.com/amtega/check_platform)
- [amtega.proxy_client](https://galaxy.ansible.com/amtega/proxy_client)
- [amtega.packages](https://galaxy.ansible.com/amtega/packages)

## Usage

<!-- Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too. For example: -->

This is an example playbook:

```yaml
---

- hosts: all
  roles:
    - role: thisrole
      thisrole_var1: value1
      thisrole_var2: value2
      thisrole_varN: valuen
```

## Testing

<!-- A description of how to run tests of the role if available. For example: -->

Tests are based on docker containers. You can setup docker engine quickly using the playbook `files/setup.yml` available in the role [amtega.docker_engine](https://galaxy.ansible.com/amtega/docker_engine).

Once you have docker, you can run the tests with the following commands:

```shell
$ cd thisrole/tests
$ ansible-playbook main.yml
```

## License

Copyright (C) <!-- YEAR --> AMTEGA - Xunta de Galicia

This role is free software: you can redistribute it and/or modify it under the terms of:

GNU General Public License version 3, or (at your option) any later version; or the European Union Public License, either Version 1.2 or – as soon they will be approved by the European Commission ­subsequent versions of the EUPL.

This role is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details or European Union Public License for more details.

## Author Information

- <!-- author _name 1 -->.
- <!-- author _name 2 -->.
- <!-- author _name N -->.
