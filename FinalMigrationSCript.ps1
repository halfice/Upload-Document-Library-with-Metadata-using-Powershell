function UploadDocuments(){
Param(
        [ValidateScript({If(Test-Path $_){$true}else{Throw "Invalid path given: $_"}})] 
        $LocalFolderLocation,
        [String] 
        $siteUrl,
        [String]
        $documentLibraryName
)
Process{
        $path = $LocalFolderLocation.TrimEnd('\')
        Write-Host "Provided Site :"$siteUrl -ForegroundColor Green
        Write-Host "Provided Path :"$path -ForegroundColor Green
        Write-Host "Provided Document Library name :"$documentLibraryName -ForegroundColor Green
          try{
                $credentials = Get-Credential  
                Connect-PnPOnline -Url $siteUrl -CreateDrive -Credentials $credentials
                $file = Get-ChildItem -Path $LocalFolderLocation -Recurse
                $i = 0;
                Write-Host "Uploading documents to Site.." -ForegroundColor Cyan
                (dir $path -Recurse) | %{
                    try{
                        $i++
                        if($_.GetType().Name -eq "FileInfo"){
                          $SPFolderName =  $documentLibraryName + $_.DirectoryName.Substring($path.Length);
                          $status = "Uploading Files :'" + $_.Name + "' to Location :" + $SPFolderName
                          $FileOwner=$_.GetAccessControl().Owner;
                          $FileOwner=$FileOwner.Substring($FileOwner.IndexOf("\")+1)
                          write-Host $FileOwner
                          $UserIDx=Get-PnPUser | Where-Object {$_.LoginName -match "$FileOwner"}
                          Write-Host $UserIDx
                          Write-Progress -activity "Uploading Documents.." -status $status -PercentComplete (($i / $file.length)  * 100)
                          $te = Add-PnPFile -Path $_.FullName -Folder $SPFolderName -Values {Author=$FileOwner.id;Created=$_.CreationTimeUtc;}
                         }          
                        }
                    catch{
                    }
                 }
            }
            catch{
             Write-Host $_.Exception.Message -ForegroundColor Red
            }
     }
}


UploadDocuments -LocalFolderLocation 'C:\Documents' -siteUrl 'https://yoursidte.sharepoint.com/Subsite' -documentLibraryName 'Documents2'


