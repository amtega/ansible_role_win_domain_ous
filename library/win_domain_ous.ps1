#!powershell

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
Set-StrictMode -Version 2.0

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        path = @{ type = "str"; required = $true }
        description = @{ type = "str" }
        managed_by = @{ type = "str" }
        protected_from_accidental_deletion = @{ type = "bool" }
        domain_server = @{ type = "str" }
        recursive = @{ type = "bool"; default = $false }
        state = @{ type = "str"; choices = "absent", "present", "query"; default = "present" }
    }
    supports_check_mode = $true
}

# ------------------------------------------------------------------------------
Function ConvertTo-DistinguishedName($identification) {
  If ($identification) {
    Try {
      If ($identification -match "^(CN|DC|OU)=") {
        # DistinguishedName
        $result = Get-ADObject -Identity $identification @extra_args
      } Else {
        # samaccountname
        $result = Get-ADObject -Filter {samaccountname -eq $identification} @extra_args
      }
      return $result.DistinguishedName
    } Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
      $module.FailJson("Object '$identification' not found in AD", $_)
    }
  }
  return $identification
}

# ------------------------------------------------------------------------------
Function Get-CanonicalDistinguishedName($distinguishedName) {
  return ($distinguishedName -split '(,?[a-z]+=)'|%{if ($_ -match '(,?[a-z]+=)'){$_.toupper()}else{$_} }) -join ''
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$path = Get-CanonicalDistinguishedName $module.Params.path
$description = $module.Params.description
$managed_by = $module.Params.managed_by
$protected_from_accidental_deletion = $module.Params.protected_from_accidental_deletion
$domain_server = $module.Params.domain_server
$recursive = $module.Params.recursive
$state = $module.Params.state

$ou_full_path = "OU=$name,$path"

$extra_args = @{}
if ($null -ne $domain_server) {
    $extra_args.ComputerName = $domain_server
}

if ($state -ne 'absent')
{
  if ($recursive -ne $false) {
    $module.FailJson("Parameter 'recursive' must be False when state='$state'", $_)
  }
}

if ($state -ne 'present')
{
  if ($description -ne $null) {
    $module.FailJson("Parameter 'description' must be empty when state='$state'", $_)
  }
  if ($managed_by -ne $null) {
    $module.FailJson("Parameter 'managed_by' must be empty when state='$state'", $_)
  }
  if ($protected_from_accidental_deletion -ne $null) {
    $module.FailJson("Parameter 'protected_from_accidental_deletion' must be empty when state='$state'", $_)
  }
}

If ($state -eq "present") {
  $managed_by = ConvertTo-DistinguishedName $managed_by
  $desired_state = [ordered]@{
    name = $name
    path = $path
    description = $description
    managed_by = $managed_by
    protected_from_accidental_deletion = $protected_from_accidental_deletion
    state = $state
  }
} Else {
  $desired_state = [ordered]@{
    name = $name
    path = $path
    state = $state
  }
}

# ------------------------------------------------------------------------------
Function Get-ActualState($desired_state) {

  $ou = Try {
      Get-ADOrganizationalUnit `
        -Identity $ou_full_path `
        -Properties Name,DistinguishedName,Description,ManagedBy,ProtectedFromAccidentalDeletion `
         @extra_args
      } Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] { $null }
  If ($ou -ne $null) {
    $initial_state = [ordered]@{
      name = $ou.Name
      # Get OU from regexp that removes all characters to the first ","
      path = Get-CanonicalDistinguishedName ($ou.DistinguishedName -creplace "^[^,]*,","")
      description = $ou.Description
      managed_by = $ou.ManagedBy
      protected_from_accidental_deletion = $ou.ProtectedFromAccidentalDeletion
      state = "present"
    }
  } Else {
    $initial_state = [ordered]@{
      name = $desired_state.name
      path = $desired_state.path
      state = "absent"
    }
  }

  return $initial_state
}

# ------------------------------------------------------------------------------
Function Set-ConstructedState($initial_state, $desired_state) {
  $ou_properties = @{
      Description = 'description'
      ManagedBy = 'managed_by'
      ProtectedFromAccidentalDeletion = 'protected_from_accidental_deletion'
  }

  Foreach ($property_in_ps_command in $ou_properties.Keys) {
    $property = $ou_properties[$property_in_ps_command]
    If ($desired_state[$property] -eq $null) {
        Continue
    }
    If ($initial_state[$property] -ne $desired_state[$property]) {
        $set_args = $extra_args.Clone()
        $set_args[$property_in_ps_command] = $desired_state[$property]
        Try {
          Set-ADOrganizationalUnit -Identity $ou_full_path -WhatIf:$module.CheckMode @set_args
        } Catch {
          $module.FailJson("Failed to set the OU property $ou_full_path[$property]: $($_.Exception.Message)", $_)
        }
        # $module.Warn("Debug: ['$property'] '$($initial_state[$property])' → '$($desired_state[$property])' ")
        $module.Result.changed = $true
    }
  }
}

# ------------------------------------------------------------------------------
Function Add-ConstructedState($desired_state) {
  Try {
    New-ADOrganizationalUnit `
      -Name $desired_state.name `
      -Path $desired_state.path `
      -Description $desired_state.description `
      -ManagedBy $desired_state.managed_by `
      -ProtectedFromAccidentalDeletion $desired_state.protected_from_accidental_deletion `
      -WhatIf:$module.CheckMode `
      @extra_args
    } Catch {
      $module.FailJson("Failed to create the OU ${ou_full_path}: $($_.Exception.Message)", $_)
    }
  # $module.Warn("Debug: Add-ConstructedState")
  $module.Result.changed = $true
}

# ------------------------------------------------------------------------------
Function Remove-ConstructedState($recursive) {
  $set_args = $extra_args.Clone()
  If ($recursive) {
    $set_args.Recursive = $true
  }
  Try {
    $SID_GROUP_ALL = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
    $acl_ou = Get-ACL -Path ("AD:\"+($ou_full_path))
    $acl_ou.RemoveAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID_GROUP_ALL,"DeleteChild, DeleteTree, Delete","Deny",([guid]'00000000-0000-0000-0000-000000000000'),"None"))
    Set-ACL -ACLObject $acl_ou -Path ("AD:\"+($ou_full_path))

    Remove-ADOrganizationalUnit $ou_full_path `
      -Confirm:$False `
      -WhatIf:$module.CheckMode `
      @extra_args
  } Catch {
    $module.FailJson("Failed to remove the OU ${ou_full_path}: $($_.Exception.Message)", $_)
  }
  # $module.Warn("Debug: Remove-ConstructedState")
  $module.Result.changed = $true
}

# ------------------------------------------------------------------------------
Function ConvertTo-SerializedState($state) {
  return @(
    $state.GetEnumerator() | ForEach-Object {
      If ($null -ne $_.Value) {
        "$($_.Name): $($_.Value)`n"
      } else {
        ""
      }
    } ) -join ''
}

# ··············································································

$initial_state = Get-ActualState $desired_state

# $module.Warn('[Debug] initial_state:' + $(ConvertTo-SerializedState $initial_state))
# $module.Warn('[Debug] desired_state:' + $(ConvertTo-SerializedState $desired_state))

If ($desired_state.state -eq "query") {
  $module.Result.value = $initial_state
  $module.ExitJson()
}

If ($desired_state.state -eq "present") {
    If ($initial_state.state -eq "present") {
      $in_desired_state = (ConvertTo-SerializedState $initial_state) -eq (ConvertTo-SerializedState $desired_state)

      If (-not $in_desired_state) {
        Set-ConstructedState $initial_state $desired_state
      }
    } Else { # $desired_state.state = "Present" & $initial_state.state = "Absent"
      Add-ConstructedState $desired_state
    }
  } Else { # $desired_state.state = "Absent"
    If ($initial_state.state -eq "present") {
      Remove-ConstructedState $recursive
    }
  }

If ($module.Result.changed) {
  $final_state = Get-ActualState $desired_state
} else {
  $final_state = $initial_state
}

if ($module.CheckMode) {
  $after_state  = $desired_state
} else {
  $after_state  = $final_state
}

$module.Result.value = $after_state

$module.Diff.before = ConvertTo-SerializedState $initial_state
$module.Diff.after  = ConvertTo-SerializedState $after_state

$module.ExitJson()
