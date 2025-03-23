# Save this as MyScript.ps1

param (
    [string]$Command,  # The command to run (e.g., luajit)
    [string]$ScriptPath  # The path to the script (e.g., test.lua)
)

# Initialize an array to store execution times
$executionTimes = @()

# Run the command 150 times
for ($i = 0; $i -lt 300; $i++) {
    $executionTime = Measure-Command { & $Command $ScriptPath > $null }
    $executionTimes += $executionTime.TotalMilliseconds
}

# Calculate the average execution time
$averageTime = ($executionTimes | Measure-Object -Average).Average

# Output the average time
"Average execution time over 150 runs: {0} ms" -f $averageTime