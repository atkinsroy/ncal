---
external help file: ncal-help.xml
Module Name: ncal
online version: https://github.com/atkinsroy/ncal/docs
schema: 2.0.0
---

# Get-Now

## SYNOPSIS

Get today's date in any of the calendars supported by .NET

## SYNTAX

```PowerShell
Get-Now [[-Calendar] <String[]>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Displays today's date in any of the calendars supported ny .NET Framework. By default, today's date for every
supported calendar is shown. The Gregorian calendar is always shown, to compare with the specified calendar.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Get-Now
```

Displays today's date in every supported calendar

### EXAMPLE 2

```PowerShell
Get-Now -Calendar Persian,Hijri,UmAlQura
```

Displays today's date for each specified calendar, along with the Gregorian calendar.

## PARAMETERS

### -Calendar

{{ Fill Calendar Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @(
            'Julian',
            'Hijri',
            'Persian',
            'UmAlQura',
            'ChineseLunisolar',
            'Hebrew',
            'Japanese',
            'JapaneseLunisolar',
            'Korean',
            'KoreanLunisolar',
            'Taiwan',
            'TaiwanLunisolar',
            'ThaiBuddhist')
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[String]

## OUTPUTS

[PSCustomObject]

## NOTES

## RELATED LINKS

[https://github.com/atkinsroy/ncal/docs](https://github.com/atkinsroy/ncal/docs)
