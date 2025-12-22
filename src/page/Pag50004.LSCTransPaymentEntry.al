page 50004 "LSC Trans. Payment Entry"
{
    ApplicationArea = All;
    Caption = 'AP Trans. Payment Entry';
    PageType = List;
    SourceTable = "LSC Trans. Payment Entry";
    UsageCategory = History;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Transaction No."; Rec."Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Transaction No. field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.', Comment = '%';
                }
                field("Statement Code"; Rec."Statement Code")
                {
                    ToolTip = 'Specifies the value of the Statement Code field.', Comment = '%';
                }
                field("Card No."; Rec."Card No.")
                {
                    ToolTip = 'Specifies the value of the Card No. field.', Comment = '%';
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                    ToolTip = 'Specifies the value of the Exchange Rate field.', Comment = '%';
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ToolTip = 'Specifies the value of the Tender Type field.', Comment = '%';
                }
                field("Amount Tendered"; Rec."Amount Tendered")
                {
                    ToolTip = 'Specifies the value of the Amount Tendered field.', Comment = '%';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.', Comment = '%';
                }
                field("Amount in Currency"; Rec."Amount in Currency")
                {
                    ToolTip = 'Specifies the value of the Amount in Currency field.', Comment = '%';
                }
                field("Card or Account"; Rec."Card or Account")
                {
                    ToolTip = 'Specifies the value of the Card or Account field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Time"; Rec."Time")
                {
                    ToolTip = 'Specifies the value of the Time field.', Comment = '%';
                }
                field("Shift No."; Rec."Shift No.")
                {
                    ToolTip = 'Specifies the value of the Shift No. field.', Comment = '%';
                }
                field("Shift Date"; Rec."Shift Date")
                {
                    ToolTip = 'Specifies the value of the Shift Date field.', Comment = '%';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ToolTip = 'Specifies the value of the Staff ID field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.', Comment = '%';
                }
                field("Transaction Status"; Rec."Transaction Status")
                {
                    ToolTip = 'Specifies the value of the Transaction Status field.', Comment = '%';
                }
                field("Statement No."; Rec."Statement No.")
                {
                    ToolTip = 'Specifies the value of the Statement No. field.', Comment = '%';
                }
                field("Managers Key Live"; Rec."Managers Key Live")
                {
                    ToolTip = 'Specifies the value of the Managers Key Live field.', Comment = '%';
                }
                field("Change Line"; Rec."Change Line")
                {
                    ToolTip = 'Specifies the value of the Change Line field.', Comment = '%';
                }
                field(Counter; Rec.Counter)
                {
                    ToolTip = 'Specifies the value of the Counter field.', Comment = '%';
                }
                field("To Account"; Rec."To Account")
                {
                    ToolTip = 'Specifies the value of the To Account field.', Comment = '%';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.', Comment = '%';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.', Comment = '%';
                }
                field("Message No."; Rec."Message No.")
                {
                    ToolTip = 'Specifies the value of the Message No. field.', Comment = '%';
                }
                field(Replicated; Rec.Replicated)
                {
                    ToolTip = 'Specifies the value of the Replicated field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Z-Report ID"; Rec."Z-Report ID")
                {
                    ToolTip = 'Specifies the value of the Z-Report ID field.', Comment = '%';
                }
                field("Tender Decl. ID"; Rec."Tender Decl. ID")
                {
                    ToolTip = 'Specifies the value of the Tender Decl. ID field.', Comment = '%';
                }
                field("Y-Report ID"; Rec."Y-Report ID")
                {
                    ToolTip = 'Specifies the value of the Y-Report ID field.', Comment = '%';
                }
                field("Replication Counter"; Rec."Replication Counter")
                {
                    ToolTip = 'Specifies the value of the Replication Counter field.', Comment = '%';
                }
                field("Safe type"; Rec."Safe type")
                {
                    ToolTip = 'Specifies the value of the Safe type field.', Comment = '%';
                }
                field("Created by Staff ID"; Rec."Created by Staff ID")
                {
                    ToolTip = 'Specifies the value of the Created by Staff ID field.', Comment = '%';
                }
                field("Cashier Report ID"; Rec."Cashier Report ID")
                {
                    ToolTip = 'Specifies the value of the Cashier Report ID field.', Comment = '%';
                }
                field("Approval Code/Ref. No."; Rec."Card Approval Code")
                {
                    Caption = 'Approval Code/Ref. No.';
                    ToolTip = 'Specifies the value of the Card Approval Code field.', Comment = '%';
                }
                field("Card Type"; Rec."Card Type")
                {
                    ToolTip = 'Specifies the value of the Card Type field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
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
            }
        }
    }
}
