#ACI

az group create --name azdiscdayrg --location eastus

az container create --name azdiscdayc1 --image microsoft/aci-helloworld --resource-group azdiscdayrg --ip-address public --ports 80

az container show --name azdiscdayc1 --resource-group azdiscdayrg

az container delete --resource-group azdiscdayrg --name azdiscday1


#AKS

Create the AKS Cluster - Note we will use this later in the containers demo.
az provider register -n Microsoft.ContainerService
az group create --name myResourceGroup --location eastus
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --generate-ssh-keys
az aks install-cli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
kubectl get nodes
kubectl create -f config.yml
kubectl get service azure-vote-front --watch
az group delete --name myResourceGroup --yes --no-wait



