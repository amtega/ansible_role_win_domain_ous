#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2019 AMTEGA - Xunta de Galicia
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_domain_ous
version_added: '2.8.2'
short_description: Manages Windows Active Directory Organizational Units
description:
     - Manages Windows Active Directory Organizational Units.
options:
  name:
    description:
      - Name of the OU (Organizational Unit) to create, remove or modify.
    type: str
    required: true
  path:
    description:
      - X.500 path of the parent OU (or container) where the new OU is created.
    type: str
    required: true
  description:
    description:
      - Description of the OU.
    type: str
  managed_by:
    description:
      - Specifies the user or group that manages the object by providing a
        distinguished name. Other acceptable  values for this parameter are
        (not recommended as they trick the task as changed):
        - A GUID (objectGUID)
        - A security identifier (objectSid)
        - A SAM account name (sAMAccountName)
    type: str
  protected_from_accidental_deletion:
    description:
        Indicates whether to prevent the object from being deleted.
          - C(yes) you cannot delete the corresponding object without changing
            the value of the property.
          - C(no) deletion isn't restricted.
    type: bool
  domain_server:
    description:
    - Specifies the Active Directory Domain Services instance to connect to.
    - Can be in the form of an FQDN or NetBIOS name.
    - If not specified then the value is based on the domain of the computer
      running PowerShell.
    type: str
  recursive:
    description:
        Indicates that this module removes the OU and any child items it
        contains. You must specify this parameter to remove an OU that is not
        empty.
          - C(yes) removes the OU and any child items it contains.
          - C(no) removes the OU (if empty).
    type: bool
    default: no
  state:
    description:
      - When C(present), creates or updates the user account.
      - When C(absent), removes the user account if it exists.
      - When C(query), retrieves the user account details without making any
        changes.
    type: str
    choices: [ absent, present, query ]
    default: present

notes:

seealso:
- module: win_domain
- module: win_domain_controller
- module: win_domain_computer
- module: win_domain_group
- module: win_domain_membership
author:
- Daniel Sánchez Fábregas (@Daniel-Sanchez-Fabregas)
'''

EXAMPLES = r'''
    - name: Query test OU state
      win_domain_ous:
        name: Commoners
        path: "OU=Black Casltle,DC=medieval,DC=time"
        state: query
      register: win_domain_ous_query_result

    - debug:
        msg: >
            Object 'OU={{ win_domain_ous_query_result.value.name }},{{
            win_domain_ous_query_result.value.path }}'
            is {{ win_domain_ous_query_result.value.state }}"
    # Output:
    # Object 'OU=Commoners,OU=Black Casltle,DC=medieval,DC=time' is absent

    - name: Create test OU
      win_domain_ous:
        name: Commoners
        path: "OU=Black Casltle,DC=medieval,DC=time"
        state: present

    - name: Modify test OU
      win_domain_ous:
        name: Commoners
        path: "OU=Black Casltle,DC=medieval,DC=time"
        description: Black Castle serfs.
        managed_by: "CN=Lord Black,OU=Black Casltle,DC=medieval,DC=time"
        protected_from_accidental_deletion: yes
        state: present

    - name: Erase test parent OU
      win_domain_ous:
        name: Black Casltle
        path: "DC=medieval,DC=time"
        recursive: yes
        state: absent
'''

RETURN = r'''
name:
    description: OU name
    returned: always
    type: str
    sample: my_ou
path:
    description: OU path
    returned: always
    type: str
    sample: OU=parent_OU,DC=company,DC=local
description:
    description: OU description
    returned: if state=present
    type: str
    sample: South office users
managed_by:
    description: User explicitly allowed to administer the OU
    returned: if state=present
    type: str
    sample: minion001
protected_from_accidental_deletion:
    description: Is the OU protected from accidental deletion
    returned: if state=present
    type: bool
    sample: No
state:
    description: The state of the OU object
    returned: always
    type: str
    sample: present
'''
