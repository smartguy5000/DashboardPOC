For(;;){
#zero out variables before beginning (helps for working on file in ISE
$main = $Null 
$i = 0 
$scriptRoot = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
if ($scriptRoot -eq $PSHOME.TrimEnd('\'))
{
    $scriptRoot = $PSScriptRoot
}
$head = (Get-Content $scriptRoot\head.html) -replace '%4',(get-date).DateTime
$tail = Get-Content $scriptRoot\tail.html

$computers = 'LD1','LD2','LD3','LD4','LD5','LDAux','LDMaster'
$adcomputers = $computers | Get-ADComputer -property OperatingSystem,LastLogonDate

ForEach ($computer in $adcomputers){
    
    #increment $i, to use the many different background image options
    $i++
    
    #set the name 
    $Name=$computer.Name
    
    #choose which style (which affect the color of the card generated)
    if (!(Test-Connection $computer -count 1 -quiet))
        {
            $style = 'style3'
            $picture = 'pic03.jpg'
            $state = 'Up'
        }
        else
        {
            $style = "style1"
            $picture = 'pic01.jpg'
            $state = 'Down'
        }
    $ProcessorStats = Get-WmiObject win32_processor -computername $computer.name
    $ComputerCpu = $ProcessorStats.LoadPercentage       
    $system = Get-WmiObject win32_OperatingSystem -computername $computer.name
    $totalPhysicalMem = $system.TotalVisibleMemorySize
    $freePhysicalMem = $system.FreePhysicalMemory
    $usedPhysicalMem = $totalPhysicalMem - $freePhysicalMem
    $usedPhysicalMemPct = [math]::Round(($usedPhysicalMem / $totalPhysicalMem) * 100,1)

    
    if ($state -eq 'Up'){
     
        $Name="$($Computer.Name)<br>
                                        RAM: $($usedPhysicalMemPct)% in Use<br>
                                        CPU: $(ForEach ($cpu in $computercpu) {"$cpu %"}) Utilization per CPU"
    }
    Else
    {
        $Name="<b>$($Computer.Name)</b>"
    }

    #Set the flavor text, which appears when we hover over the card
    $description= @"
        Currently $($computer.DNSHostName) is $($state)<br>
                                            It is running $($computer.OperatingSystem)<br>
                                            Last Logon Date and Time $($computer.LastLogonDate)
"@

    #make a card
    $tile = @"

                                <article class="$style">
									<span class="image">
										<img src="images/$picture" alt="" />
									</span>
									<a href="index.html">
										<h2>$Name</h2>
										<div class="content">
											<p>$($description)</p>
										</div>
									</a>
								</article>
"@


$main += $tile
}
Copy-Item -Path $scriptRoot\head.html -Destination $scriptRoot\index.html -Force
Add-Content -Value $main -LiteralPath $scriptRoot\index.html
Add-Content -Value $tail -LiteralPath $scriptRoot\index.html
Start-Sleep -Seconds 15}
