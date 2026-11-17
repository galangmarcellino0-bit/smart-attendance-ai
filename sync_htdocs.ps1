# Helper script to sync workspace to XAMPP htdocs
$source = "C:\Users\GALANG.M\OneDrive\Documents\tugas prd"
$dest = "C:\xampp\htdocs\tugas prd"
robocopy $source $dest /MIR /XD .git node_modules
Write-Host "Sync to XAMPP htdocs completed successfully." -ForegroundColor Green
