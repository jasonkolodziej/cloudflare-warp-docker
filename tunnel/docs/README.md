# cloudflared

## SSH access via Cloudflare Tunnel

Generate an SSH config snippet for short-lived certificate access to a Cloudflare-tunnelled host:

```shell
./cloudflared access ssh-config --hostname <your-hostname> --short-lived-cert
```

Example output — add the generated block to `~/.ssh/config`:

```
Match host <your-hostname> exec "cloudflared access ssh-gen --hostname %h"
  ProxyCommand cloudflared access ssh --hostname %h
  IdentityFile ~/.cloudflared/%h-cf_key
  CertificateFile ~/.cloudflared/%h-cf_key-cert.pub
```

Replace `<your-hostname>` with the public hostname you configured in the Cloudflare Zero Trust dashboard (e.g. `ssh.example.com`).

After adding the config block, connect normally:

```shell
ssh <your-hostname>
```

### debugging `cloudflared`

```sh
/cdata # tree etc/ssl/
etc/ssl/
└── certs
    └── ca-certificates.crt # global ca's provided by cloudflare

1 directories, 1 files



/cdata # find . -type f -iname '*cloudflare*'
./usr/local/bin/cloudflared
/cdata # 
```