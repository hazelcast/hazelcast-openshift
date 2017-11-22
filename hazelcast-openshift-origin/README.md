# Hazelcast OpenShift

## Supported Versions

Hazelcast OpenShift supports:
* `OC v1.4.1+`
* `Kubernetes v1.4.0+`

_Please note that the Docker image of this distribution is based on the
[`hazelcast-kubernetes` image](https://github.com/hazelcast/hazelcast-docker)._

## Usage

First login to OpenShift using the OpenShift CLI with the following commands:

```
sudo su
oc login <your-openshift-login-url>
```

Then create a new project, e.g., `hazelcast-cluster`, and switch to that newly created using the following commands:

```
oc new-project hazelcast-cluster
oc project hazelcast-cluster
```

Now download the project template from GitHub and use CLI to register the template under the newly created project using the following commands:

```
curl -o hazelcast-template.json https://raw.githubusercontent.com/hazelcast/hazelcast-openshift/master/hazelcast-openshift-origin/hazelcast-template.json
oc create -f hazelcast-template.json -n hazelcast-cluster
```

Finally, login to your OpenShift Web Administration UI. You should see your new Hazelcast template and start creating a Hazelcast cluster by filling the parameters according to your needs.

For detailed information please see our blog post at http://blog.hazelcast.com/openshift/.

Hazelcast Openshift : https://hub.docker.com/r/hazelcast/hazelcast-openshift-origin/
