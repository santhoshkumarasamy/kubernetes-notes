New person
The following scripts show how to generate PKI private key and CSR. It is important to set CN and O attribute of the CSR. CN is the name of the user and O is the group that this user will belong to.
```
openssl genrsa -out adam.key 2048
openssl req -new -key adam.key -out adam.csr -subj "/CN=adam"
```

Now the existing adim

```
#convert the csr into base64 and remove the line breaks

cat myuser.csr | base64 | tr -d "\n"

```

create a csr yaml

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser
spec:
  request:LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZEQ0NBVHdDQVFBd0R6RU5NQXNHQTFVRUF3d0VZV1JoYlRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRApnZ0VQQURDQ0FRb0NnZ0VCQU5xTUo0NFJlV1dHeWlvdU9DWEl6TXUrRlh6SUU1d0JXOHZNQVg3ZXQrWk5JcDRQCnp4dWlTVFNJUnl0MkJqN24zN1cxVVJtLyt6aUR2UHh6clJkVHI5b0ZCeHhJaXhCdXUySkhubUVCb0ZJYkorTU0KOE5GV0x2eDMxd0t5cmFOUVpnT0g5bU9XZjVpS0tjdWJNS3czVThsTW04ekMxMlRSY3lTRTdoeUZ6dFduR2dnKwpObFJTZXpaT2t1N0FBdGI0S3YyTVhsSTlSbDVQUUdoMlFkcHlDeTdvYjNyS2pkUmtGVXd5Y0kyUG16Z0JCZGo2CjA2R2I2NEJQZFFXWkplWWhSYW56QVVGanVUb1FvZk1SRTRVc3c2SFd2bUdFcjFQZVVXRWlqSkdzY1orMzc2MkwKalAwTlRGRGFwUmFJdHIrbkpxK1ppMjlJRlF4ZXY4bUpvVE1zQWJNQ0F3RUFBYUFBTUEwR0NTcUdTSWIzRFFFQgpDd1VBQTRJQkFRQ3dkUDVVV1NQNGlYS3J5d2FPa01JM1FxNTJPdTlZL3lNYjVZa0RNd2wwZmpUelExSmg5MVErCk52eGxWb1FaYmIwQVUvM3l2R0xESTdYQ2k4eGtuaWw0UXFnZS9lSTF4blVQWkJEN3h2U045MGJUeUtvYWNRMkEKcHRVV1NJTmNrRUxyRG5ZQk05blVla09GUllzVC9iQThsREZKSXFNYVZtSkhoWTZJemd5WWh1V3pTZ2NTS2xyOAo2Q0lhSWZGK004Q3U0M2VGSldvcUNtdmE1bDBNQmtpbEFwZVQ0TWxYUjJkc1YyV3QwRHFqYytsZXhNR01zMTB0CkRHMEtXQTlld25oTDNzaThyVXdTakxMajg0azNQSU92dFlOZ3d4MHJzb2dFeWRaWUhQSUJxejFSQmZvM1l5U0EKYjRnSS92YTdMalpFMXVtMUZib1A1UzZQMmZvcDN4eUMKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg 
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
```

now raise the csr

```
kubectl apply -f adam-csr.yaml

# get the csr

kubectl get csr #or certificatesigningrequest

```

now that the request is made it has to be approved by a CA (certificate authority)

Since this is a internal (not public) the master node has a ca

to approve the request the user should have a permission
check this link

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/

it is covered here

to approve the request
```
k certificate approve adam #request name
```

```
# to get the cert and send to adam
k get csr adam -o yaml > issuedcert.yaml

```
The certificate value is in Base64-encoded format under status.certificate.

Export the issued certificate from the CertificateSigningRequest

```
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
#or export it to a file then decode from base 64
```

now the csr is approved, now we have to add permission to the certificate

we will see that in next sessions

