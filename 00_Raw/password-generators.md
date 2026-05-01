
## One Liner Password Generator:
-join([Security.Cryptography.RandomNumberGenerator]::GetBytes(18)|% ToString x2)

## Two Line Password Generator:
$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+='
-join (1..20 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })

## Golf'ed One Line Password Generator:
[IO.Path]::GetRandomFileName()