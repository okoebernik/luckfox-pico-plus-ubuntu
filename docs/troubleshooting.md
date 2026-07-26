# Troubleshooting

## Clock Skew

Restart WSL:

``` powershell
wsl --shutdown
```

## Out of Memory

Verify swap:

``` bash
swapon --show
```

## SSH Public Key

Test:

``` bash
ssh -T git@github.com
```
