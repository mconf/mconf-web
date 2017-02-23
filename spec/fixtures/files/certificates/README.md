These files are certificates created to test the authentication using certificates.

Files:

* `ca.key`: The key for the Certificate Authority that signs the client certificates.
* `ca.crt`: The certificate of the Certificate Authority that signs the client certificates.
* `client*.key`: The key for a test client.
* `client*.csr`: The csr file for a test client.
* `client*.crt`: The certificate file for a test client (what is actually used on tests).

All passwords used to generate the keys and certificates are: `1234`.

They were created using the following steps (taken from [here](https://gist.github.com/mtigas/952344)):

## Create a Certificate Authority root (which represents this server)

Organization & Common Name: Some human identifier for this server CA.

```
openssl genrsa -des3 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
```

## Create the Client Key and CSR

Organization & Common Name = Person name

```
openssl genrsa -des3 -out client.key 4096
openssl req -new -key client.key -out client.csr
# self-signed
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
```
