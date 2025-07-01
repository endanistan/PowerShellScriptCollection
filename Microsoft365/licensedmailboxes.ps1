#Sort exchange mailboxes for sharedmailboxes only and download the csv file to a local path.
connect-mggraph -tenantid "<tenant id>" -scope "User.ReadWrite.All" -nowelcome

$csvpath = "<path to csv file>"
$ids = import-csv -path $csvpath | select-object -expandproperty objectid
foreach ($id in $ids) {
    $licensed = get-mguserlicensedetail -userid $id
    if ($licensed) {
        $user = (get-mguser -userid $id).userprincipalname
        write-host "User $user have a license assigned."
    }
}