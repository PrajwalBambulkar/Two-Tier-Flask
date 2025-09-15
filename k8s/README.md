# How to setup two-tier application deployment on kubernetes cluster
## First setup kubernetes kubeadm cluster
Use this repository to setup kubeadm https://github.com/LondheShubham153/kubestarter/blob/main/kubeadm_installation.md

## SetUp
- First clone the code to your machine
```bash
git clone https://github.com/LondheShubham153/two-tier-flask-app.git
```
- Move to k8s directory
```bash
cd two-tier-flask-app/k8s
```
- Now, execute below commands one by one
```bash
kubectl apply -f twotier-deployment.yml
```
```bash
kubectl apply -f twotier-deployment-svc.yml
```
```bash
kubectl apply -f mysql-deployment.yml
```
```bash
kubectl apply -f mysql-deployment-svc.yml
```
```bash
kubectl apply -f persistent-volume.yml
```
```bash
kubectl apply -f persistent-volume-claim.yml
```
Add service DNS in your app deployment (do not hardcode ClusterIP):
```bash
- name: MYSQL_HOST
  value: "mysql"
```

### **Install Argo CD and access UI**
- Install Argo CD in argocd namespace:
- kubectl create namespace argocd
- kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#### Expose Argo CD server for local access (NodePort):
- kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "NodePort"}}'
- kubectl -n argocd get svc argocd-server

#### Open http://<node-ip>:<nodeport> in browser.
- Get initial admin password:
- kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
- Login UI: admin / (password above). Optional: change password.

##### cd argocd-apps
```bash
kubectl apply -f .
```

### Error if you get
- MySQLdb.ProgrammingError: (1146, "Table 'mydb.messages' doesn't exist")
- Cause: DB schema (table) missing.Fix: Connect to MySQL and run DDL or use migrations.
- # then run CREATE TABLE ...

### SharedResourceWarning & argocd.argoproj.io/tracking-id conflicts (PV ownership)
##### Cause: Two Argo CD apps try to manage the same cluster-scoped resource (PV/PVC). Argo CD annotates resources with a tracking id. Fixes (pick one):
- Move PV manifests out of Git or keep PV only in mysql-app (recommended).
- Change PV reclaimPolicy to Retain to avoid accidental data removal.
- Or tell Argo CD to ignoreDifferences for the PV tracking annotation.
```bash
ignoreDifferences:
- group: ""
kind: PersistentVolume
name: mysql-pv
jsonPointers:
- /metadata/annotations/argocd.argoproj.io~1tracking-id
```

#### SharedResourceWarning: Deployment/two-tier-app is part of applications ...
- Cause: Both ArgoCD apps pointed to the same k8s/ path and applied overlapping resources. Fix: Move manifests to separate subfolders and point each ArgoCD Application to its path.

