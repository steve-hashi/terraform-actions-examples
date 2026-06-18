schedule "weekday_ec2_shutdown" {   
    # Runs at 5:00 PM, Monday–Friday   
    days    = [ "Monday". "Tuesday", "Wednesday", "Thursday", "Friday" ]
    times   = [ "17:00" ]
    timezone = "America/New_York"  # optional but recommended    
    
    # Direct reference to the Action that performs the shutdown
    actions = [ "shutdown-ec2-instance"]    
    
    enabled = true # optional, defaults to true 
} 