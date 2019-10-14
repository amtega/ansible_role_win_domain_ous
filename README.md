# Ansible win_domain_ous

This is an [Ansible](http://www.ansible.com) role which setups windows active directory organizational units.

## Role Variables

A list of all the default variables for this role is available in `defaults/main.yml`.

## Modules

The role provides these modules:

- `win_domain_ous`: setups windows an active directory domain single OU

## Usage

This is an example playbook:

```yaml
---

- hosts: windows_ad_computer
  roles:
    - role: amtega.win_domain_ous
  vars:
    win_domain_ous_defaults:
      path: "OU=Black Casltle,DC=medieval,DC=time"

    win_domain_ous:
      - name: Commoners
        description: Black Castle serfs.
        state: present
      - name: Knights
        description: Black Knights.
        state: present
```

## Testing

To run test you must pass in the command line the variable `win_domain_ous_tests_host` pointing to a windows host fullfilling the ansible requirements documented in https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html. Also, you must define in the inventory for this host the neccessary variables to connect.

Additionally the tests requires the following set of variables that can be defined in the inventory or passed in the command line:

- `win_domain_ous_tests_ad_ou`: Base OU to use during tests
- `win_domain_ous_tests_managed_by`: User to test managed_by OU property

One way to provide all the previous information is calling the testing playbook passing the host to use and an additional vault inventory plus the default one provided for testing, as it's show in this example:

```shell
$ cd amtega.win_domain_groups/tests
$ ansible-playbook main.yml -e "win_domain_ous_tests_host=test_host" -i inventory -i ~/mycustominventory.yml --vault-id myvault@prompt
```

## License

Copyright (C) 2019 AMTEGA - Xunta de Galicia

This role is free software: you can redistribute it and/or modify it under the terms of:

GNU General Public License version 3, or (at your option) any later version; or the European Union Public License, either Version 1.2 or – as soon they will be approved by the European Commission ­subsequent versions of the EUPL.

This role is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details or European Union Public License for more details.

## Author Information

- Daniel Sánchez Fábregas.
