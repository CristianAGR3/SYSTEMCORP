param(
  [Parameter(Mandatory = $true)]
  [string]$Password
)

$iterations = 310000
$salt = New-Object byte[] 16
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($salt)

$pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
  $Password,
  $salt,
  $iterations,
  [System.Security.Cryptography.HashAlgorithmName]::SHA256
)

$hash = $pbkdf2.GetBytes(32)
$salt64 = [Convert]::ToBase64String($salt)
$hash64 = [Convert]::ToBase64String($hash)

Write-Output "pbkdf2-sha256`$$iterations`$$salt64`$$hash64"
