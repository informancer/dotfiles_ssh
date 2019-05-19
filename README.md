# dotfiles_ssh
## Installation
### common part
Checkout this repo with [vcsh](https://github.com/RichiH/vcsh).
In your vcsh repo, enable sparse checkouts:

`git config  --local --add core.sparsecheckout true`

Then configure sparse checkout to ignore some files:

```
cat >> "$GIT_DIR/info/sparse-checkout" << EOF
*
!README*
!LICENSE*
!test
EOF
```

Finally, ensure that `$HOME/.local/bin` is in you path.
### Private part
create a second vcsh repo used only for the content of .ssh/config.d
## Usage
### ssh-new-key
`ssh-new-key` generates a new key for a given host.
## Development
### Testing
Testing is done using [bats](https://github.com/bats-core/bats-core).
### Exit Codes
As proposed in https://www.tldp.org/LDP/abs/html/exitcodes.html#EXITCODESREF,
the return values will be as defined in
`/usr/include/sysexits.h`
