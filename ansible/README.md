# VULTR Ansible examples

These examples use the [vultr.cloud](https://docs.ansible.com/ansible/latest/collections/vultr/cloud/index.html) collection. In order to use it, run

```
ansible-galaxy collection install vultr.cloud --upgrade
```

## inventory

The `vultr.yml` file shows how to use the vultr API as an Ansible inventory. You need to replace th api key with your own of course.

## playbooks

There are 2 playbooks here:

### Create an instance

the playbook `create_instance.yaml` creates a new instance on VULTR and takes the following variables:

- `{{ vultr_api_key }}` - your API key
- `{{ vultr_host_label }}` - the label of the new host. This will be the hostname in the inventory later!
- `{{ vultr_host_name }}` - the (DNS) host name
- `{{ vultr_plan }}` - the plan (i.e. size and price) of the instance, e.g. `vc2-1c-2gb`
- `{{ vultr_region }}` - the region / country, e.g. `cdg` for Paris or `lax` for Los Angeles

Furthermore it is assumed that you have created an ssh key in your Vultr Web interface calle `ansible_key` - this is the ssh key that you can use to connect to the instance later

### Destroy an instance

the playbook `destroy_instance.yaml` destroys / deletes an instance from VULTR and takes the following variables:

- `{{ vultr_api_key }}` - your API key
- `{{ vultr_host_label }}` - the label of the host that needs to be deleted.
- `{{ vultr_region }}` - the region / country, e.g. `cdg` for Paris or `lax` for Los Angeles

