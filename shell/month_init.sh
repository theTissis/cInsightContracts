source .env
# specify the address of Bonfire as the first argument:
# 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e
cast send $1 "monthInit()()"  --private-key $DEPLOYER_KEY
