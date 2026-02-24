function Write-ZodiacAnimal {
    [CmdletBinding()]
    <#
        .NOTES
        Helper function for Get-NCalendar and Get-Calendar. Returns the zodiac animal for the specified lunar
        calendar. The Chinese, Japanese, Korean and Taiwanese Lunar years are based on the same 12-year cycle, but
        have different starting points. The Chinese and Korean Lunar year follows the Gregorian Calendar. The
        Japanese Lunar year follows the reign of the current emperor (Emperor Naruhito), which started in 2019
        (Year 1). The Taiwanese Lunar year follows the Republic of China calendar, which started in 1912 (Year 1).
    #>
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Calendar,

        [Parameter(Mandatory, Position = 1)]
        [int]$Year,

        [Parameter(Mandatory, Position = 2)]
        [Object]$Pretty
    )

    process {
        switch ($Calendar) {
            'JapaneseLunisolar' {
                $Animal = @('Rat (子 -nezumi)', 'Ox (丑 -ushi)', 'Tiger (寅 -tora)', 'Rabbit (卯 -u)', 'Dragon (辰 -tatsu)', 'Snake (巳 -hebi)', 'Horse (午 -uma)', 'Goat (未 -hitsuji)', 'Monkey (申 -saru)', 'Rooster (酉 -tori)', 'Dog (戌 -inu)', 'Boar (亥 -inoshishi)')
                $AnimalIndex = (2018 + $Year - 4) % 12
                break 
            }
            'KoreanLunisolar' { 
                $Animal = @('Rat (쥐 - Jwi)', 'Ox (소 - So)', 'Tiger (호랑이 - Horangi)', 'Rabbit (토끼 - Tokki)', 'Dragon (용 - Yong)', 'Snake (뱀 - Baem)', 'Horse (말 - Mal)', 'Sheep/Goat (양 - Yang)', 'Monkey (원숭이 - Wonsungi)', 'Rooster (닭 - Dak)', 'Dog (개 - Gae)', 'Pig (돼지 - Dwaeji)')
                $AnimalIndex = ($Year - 4) % 12
                break 
            }
            'TaiwanLunisolar' { 
                $Animal = @('Rat (鼠 -shǔ)', 'Ox (牛 -niú)', 'Tiger (虎 -hǔ)', 'Rabbit (兔 -tù)', 'Dragon (龙 -lóng)', 'Snake (蛇 -shé)', 'Horse (马 -mǎ)', 'Goat (羊 -yáng)', 'Monkey (猴 -hóu)', 'Rooster (鸡 -jī)', 'Dog (狗 -gǒu)', 'Pig (猪 -zhū)')
                $AnimalIndex = (1911 + $Year - 4) % 12
                break 
            }
            default { 
                $Animal = @('Rat (鼠 -shǔ)', 'Ox (牛 -niú)', 'Tiger (虎 -hǔ)', 'Rabbit (兔 -tù)', 'Dragon (龙 -lóng)', 'Snake (蛇 -shé)', 'Horse (马 -mǎ)', 'Goat (羊 -yáng)', 'Monkey (猴 -hóu)', 'Rooster (鸡 -jī)', 'Dog (狗 -gǒu)', 'Pig (猪 -zhū)')
                $AnimalIndex = ($Year - 4) % 12
                
            } 
        }
        $ZodiacAnimal = $Animal[$AnimalIndex]
        Write-Output "`n$($Pretty.MonStyle)This is the year of the $ZodiacAnimal.$($Pretty.MonReset)`n"
    }
}
