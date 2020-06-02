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

Tests are based on [molecule with virtual machines](https://molecule.readthedocs.io/en/latest/installation.html).


```shell
$ cd cd amtega.win_domain_groups
$ molecule test
```

## License

Copyright (C) 2020 AMTEGA - Xunta de Galicia

This role is free software: you can redistribute it and/or modify it under the terms of:

GNU General Public License version 3, or (at your option) any later version; or the European Union Public License, either Version 1.2 or – as soon they will be approved by the European Commission ­subsequent versions of the EUPL.

This role is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details or European Union Public License for more details.

## Author Information

- Daniel Sánchez Fábregas.
