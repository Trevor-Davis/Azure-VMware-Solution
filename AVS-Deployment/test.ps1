while(1) {
  try {

       $requests = Invoke-WebRequest -Uri "https://192.168.99.10" -Method GET -SkipCertificateCheck -TimeoutSec 5
       
      if($requests.StatusCode -eq 200) {
          Write-Host -ForegroundColor Green "
Success: HCX Manager is now ready to be configured!"
          break
      }
  }
  catch {
      Write-Host -ForegroundColor Yellow "
HCX Manager Still Getting Ready ... Will Check Again In 1 Minute ..."
      Start-Sleep 60
  }
}
