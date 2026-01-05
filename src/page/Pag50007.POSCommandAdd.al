page 50007 POSCommandAdd
{
    ApplicationArea = All;
    Caption = 'POSCommandAdd';
    PageType = List;
    SourceTable = "LSC POS Command";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Background Fading"; Rec."Background Fading")
                {
                    ToolTip = 'Specifies the value of the Background Fading field.', Comment = '%';
                }
                field(Blocking; Rec.Blocking)
                {
                    ToolTip = 'Specifies if the command should block the User Interface until the server has finished handling it (by default, button clicks are non-blocking). This is useful when operations on the server take a long time, e.g. for slow network connections. Use POS Interface Profile to apply this setting to all commands.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the command. This field cannot be edited.';
                }
                field("Description Text"; Rec."Description Text")
                {
                    ToolTip = 'Specifies a text that describes the functionality of the POS Command.';
                }
                field("Field Link"; Rec."Field Link")
                {
                    ToolTip = 'Specifies the number of the field that this parameter is linked to. If a parameter is linked to a table and field you can look up the value from that table/field when setting up the parameter values.';
                }
                field(Font; Rec.Font)
                {
                    ToolTip = 'Specifies the value of the Font field.', Comment = '%';
                }
                field("Forecourt Action"; Rec."Forecourt Action")
                {
                    ToolTip = 'Specifies the value of the Forecourt Action field.', Comment = '%';
                }
                field("Forecourt Action 2"; Rec."Forecourt Action 2")
                {
                    ToolTip = 'Specifies the value of the Forecourt Action 2 field.', Comment = '%';
                }
                field("Function Code"; Rec."Function Code")
                {
                    ToolTip = 'Specifies the code of the POS command. This field cannot be edited. The table nproverview_99008901 explains the properties of and/or method of use for each LS POS command.';
                }
                field("Function Type"; Rec."Function Type")
                {
                    ToolTip = 'Specifies the function type of the POS Command. POS Internal: A command created by LS Retail. POS External: A customization or functionality that is added to the Standard POS Commands. A codeunit is specified for executing an external command.';
                }
                field("MSR Action"; Rec."MSR Action")
                {
                    ToolTip = 'Specifies the value of the MSR Action field.', Comment = '%';
                }
                field("MSR Action 2"; Rec."MSR Action 2")
                {
                    ToolTip = 'Specifies the value of the MSR Action 2 field.', Comment = '%';
                }
                field("Manager Key"; Rec."Manager Key")
                {
                    ToolTip = 'Specifies whether you need to have manager rights to use this command. This field is editable.';
                }
                field("Menu Function"; Rec."Menu Function")
                {
                    ToolTip = 'Specifies whether the command can be used in a menu. Otherwise it is an internal command. This field cannot be edited.';
                }
                field("Outbound Code"; Rec."Outbound Code")
                {
                    ToolTip = 'Specifies the value of the Outbound Code field.', Comment = '%';
                }
                field("POS Button Description"; Rec."POS Button Description")
                {
                    ToolTip = 'Specifies the text that is entered as Description when the command is assigned to a POS Menu Line. This is used for example when a POS Tag is used to vary the description of the command on a button.';
                }
                field("POS Help ID"; Rec."POS Help ID")
                {
                    ToolTip = 'Specifies the value of the POS Help ID field.', Comment = '%';
                }
                field("POS Module"; Rec."POS Module")
                {
                    ToolTip = 'Specifies the POS Module that this parameter applies to.';
                }
                field("POS Panel ID"; Rec."POS Panel ID")
                {
                    ToolTip = 'Specifies the value of the POS Panel ID field.', Comment = '%';
                }
                field("Parameter Type"; Rec."Parameter Type")
                {
                    ToolTip = 'Specifies the value of the Parameter Type field.', Comment = '%';
                }
                field("Pop-up Function"; Rec."Pop-up Function")
                {
                    ToolTip = 'Specifies the value of the Pop-up Function field.', Comment = '%';
                }
                field(Prompt; Rec.Prompt)
                {
                    ToolTip = 'Specifies a text that appears on the display when the command prompts for information or action. This field is editable.';
                }
                field("Run Codeunit"; Rec."Run Codeunit")
                {
                    ToolTip = 'Specifies the number of the Codeunit that executes the POS Command.';
                }
                field("Scanner Action"; Rec."Scanner Action")
                {
                    ToolTip = 'Specifies the status of the scanner during the command. Blank: The command has no effect on the status of the scanner. Enable: The command enables the scanner. This is recommended if the command requires input from the scanner. Disable: The command disables the scanner. This is recommended if the command requires input from, and enables, another device.';
                }
                field("Scanner Action 2"; Rec."Scanner Action 2")
                {
                    ToolTip = 'Specifies the value of the Scanner Action 2 field.', Comment = '%';
                }
                field("Set POS State"; Rec."Set POS State")
                {
                    ToolTip = 'The program uses this field internally.';
                }
                field(Skin; Rec.Skin)
                {
                    ToolTip = 'Specifies the value of the Skin field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Table Link"; Rec."Table Link")
                {
                    ToolTip = 'Specifies the number of the table that this parameter is linked to. If a parameter is linked to a table and field, you can look up the value from that table/field when setting up the parameter values.';
                }
            }
        }
    }
}
