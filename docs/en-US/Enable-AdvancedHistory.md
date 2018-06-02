---
external help file: AdvancedHistory-help.xml
Module Name: AdvancedHistory
online version: 1.0.0.0
schema: 2.0.0
---

# Enable-AdvancedHistory

## SYNOPSIS
Enable keyboard navigable history.

## SYNTAX

```
Enable-AdvancedHistory [[-Shortcut] <String>] [-Unique] [<CommonParameters>]
```

## DESCRIPTION
Adds a keyboard shortcut (Default: F7) to trigger a keyboard navigable command history of executed commands.

* Up/Down Arrows: Navigate the list
* Right/Left Arrows: Change the page
* Enter/Return: Select the highlighted line item
* Esc: Cancel

## EXAMPLES

### Example 1
```
PS C:\> Enable-AdvancedHistory -Unique
```

Enables the AdvancedHistory menu using the defauly F7 keyboard shortcut and will only show unique history items.

## PARAMETERS

### -Shortcut
The keyboard shortcut to trigger the history menu. (Default: F7)

```yaml
Type: String
Parameter Sets: (All)
Aliases: Key

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unique
Only display unique executions from the history. (For example, if you have run `cd c:\temp` multiple times only the most recent will appear.)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS

