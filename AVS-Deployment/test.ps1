function test($test1, $test2)
{
 $details = @{ 
 "updateDetails"= 
 @(
    
    @{
        "school" = "western"
        "address" = $test2
    }
    )
}

return $details | ConvertTo-Json
}

test 0 florida


#azure login function
function jsonfile {

    param ($test1,$test2)
    $payload = @{
        "customer" = $test2
        "rank" = $test1
        "test" = {
            "customer" = $test2
            "customer" = $test1
        }
    }
    return $payload | ConvertTo-Json

}