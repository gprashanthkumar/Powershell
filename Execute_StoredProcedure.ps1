function Execute-Stored-Procedure
{
    param($server, $db, $spname)
    $sqlConnection = new-object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = 'server=' + $server + ';integrated security=TRUE;database=' + $db 
    $sqlConnection.Open()
    $sqlCommand = new-object System.Data.SqlClient.SqlCommand
    $sqlCommand.CommandTimeout = 120
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandType= [System.Data.CommandType]::StoredProcedure
    # If you have paramters, add them like this:
    # $sqlCommand.Parameters.AddWithValue("@paramName", "$param") | Out-Null
    $sqlCommand.CommandText= $spname
    $text = $spname.Substring(0, 50)
    Write-Progress -Activity "Executing Stored Procedure" -Status "Executing SQL => $text..."
    Write-Host "Executing Stored Procedure => $text..."
    $result = $sqlCommand.ExecuteNonQuery()
    $sqlConnection.Close()
}


# Call like this:
Execute-Stored-Procedure -server "BYUS226VXYE" -db "WavesDB" -spname "spImportHCXMigration_VM_Status"
