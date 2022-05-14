## freerdp-proxy

快速部署

```bash
docker build -t freerdp-proxy:dev .
docker run --name freerdp-proxy -d -p 3389:3389 -e HOST_IP=<yourAssetIP> freerdp-proxy:dev
```
