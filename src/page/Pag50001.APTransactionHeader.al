page 50001 "AP Transaction Header"
{
    ApplicationArea = All;
    Caption = 'AP Transaction Header';
    PageType = List;
    SourceTable = "LSC Transaction Header";
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
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ToolTip = 'Specifies the value of the Transaction Type field.', Comment = '%';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.', Comment = '%';
                }
                field("VAT Bus.Posting Group"; Rec."VAT Bus.Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Bus.Posting Group field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.', Comment = '%';
                }
                field("Created on POS Terminal"; Rec."Created on POS Terminal")
                {
                    ToolTip = 'Specifies the value of the Created on POS Terminal field.', Comment = '%';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ToolTip = 'Specifies the value of the Staff ID field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Original Date"; Rec."Original Date")
                {
                    ToolTip = 'Specifies the value of the Original Date field.', Comment = '%';
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
                field("Wrong Shift"; Rec."Wrong Shift")
                {
                    ToolTip = 'Specifies the value of the Wrong Shift field.', Comment = '%';
                }
                field("Infocode Disc. Group"; Rec."Infocode Disc. Group")
                {
                    ToolTip = 'Specifies the value of the Infocode Disc. Group field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ToolTip = 'Specifies the value of the Transaction Code field.', Comment = '%';
                }
                field("Trans. Sale/Pmt. Diff."; Rec."Trans. Sale/Pmt. Diff.")
                {
                    ToolTip = 'Specifies the value of the Trans. Sale/Pmt. Diff. field.', Comment = '%';
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ToolTip = 'Specifies the value of the Net Amount field.', Comment = '%';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ToolTip = 'Specifies the value of the Cost Amount field.', Comment = '%';
                }
                field("Gross Amount"; Rec."Gross Amount")
                {
                    ToolTip = 'Specifies the value of the Gross Amount field.', Comment = '%';
                }
                field(Payment; Rec.Payment)
                {
                    ToolTip = 'Specifies the value of the Payment field.', Comment = '%';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Amount field.', Comment = '%';
                }
                field("Customer Discount"; Rec."Customer Discount")
                {
                    ToolTip = 'Specifies the value of the Customer Discount field.', Comment = '%';
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    ToolTip = 'Specifies the value of the Total Discount field.', Comment = '%';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.', Comment = '%';
                }
                field("No. of Items"; Rec."No. of Items")
                {
                    ToolTip = 'Specifies the value of the No. of Items field.', Comment = '%';
                }
                field("Amount to Account"; Rec."Amount to Account")
                {
                    ToolTip = 'Specifies the value of the Amount to Account field.', Comment = '%';
                }
                field(Rounded; Rec.Rounded)
                {
                    ToolTip = 'Specifies the value of the Rounded field.', Comment = '%';
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                    ToolTip = 'Specifies the value of the Customer Disc. Group field.', Comment = '%';
                }
                field("Entry Status"; Rec."Entry Status")
                {
                    ToolTip = 'Specifies the value of the Entry Status field.', Comment = '%';
                }
                field("No. of Invoices"; Rec."No. of Invoices")
                {
                    ToolTip = 'Specifies the value of the No. of Invoices field.', Comment = '%';
                }
                field("No. of Item Lines"; Rec."No. of Item Lines")
                {
                    ToolTip = 'Specifies the value of the No. of Item Lines field.', Comment = '%';
                }
                field("Statement Code"; Rec."Statement Code")
                {
                    ToolTip = 'Specifies the value of the Statement Code field.', Comment = '%';
                }

                field("Refund Receipt No."; Rec."Refund Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Refund Receipt No. field.', Comment = '%';
                }
                field("Income/Exp. Amount"; Rec."Income/Exp. Amount")
                {
                    ToolTip = 'Specifies the value of the Income/Exp. Amount field.', Comment = '%';
                }
                field("To Account"; Rec."To Account")
                {
                    ToolTip = 'Specifies the value of the To Account field.', Comment = '%';
                }
                field("No. of Payment Lines"; Rec."No. of Payment Lines")
                {
                    ToolTip = 'Specifies the value of the No. of Payment Lines field.', Comment = '%';
                }
                field("Sale Is Return Sale"; Rec."Sale Is Return Sale")
                {
                    ToolTip = 'Specifies the value of the Sale Is Return Sale field.', Comment = '%';
                }
                field("Sale Is Exchange Sale"; Rec."Sale Is Exchange Sale")
                {
                    ToolTip = 'Specifies the value of the Sale Is Exchange Sale field.', Comment = '%';
                }
                field("Trans. Is Mixed Sale/Refund"; Rec."Trans. Is Mixed Sale/Refund")
                {
                    ToolTip = 'Specifies the value of the Trans. Is Mixed Sale/Refund field.', Comment = '%';
                }
                field("Reverted Gross Amount"; Rec."Reverted Gross Amount")
                {
                    ToolTip = 'Specifies the value of the Reverted Gross Amount field.', Comment = '%';
                }
                field(Counter; Rec.Counter)
                {
                    ToolTip = 'Specifies the value of the Counter field.', Comment = '%';
                }
                field("Time when Total Pressed"; Rec."Time when Total Pressed")
                {
                    ToolTip = 'Specifies the value of the Time when Total Pressed field.', Comment = '%';
                }
                field("Time when Trans. Closed"; Rec."Time when Trans. Closed")
                {
                    ToolTip = 'Specifies the value of the Time when Trans. Closed field.', Comment = '%';
                }
                field("Trans. Currency"; Rec."Trans. Currency")
                {
                    ToolTip = 'Specifies the value of the Trans. Currency field.', Comment = '%';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the value of the Currency Factor field.', Comment = '%';
                }
                field("Items Posted"; Rec."Items Posted")
                {
                    ToolTip = 'Specifies the value of the Items Posted field.', Comment = '%';
                }
                field("Post as Shipment"; Rec."Post as Shipment")
                {
                    ToolTip = 'Specifies the value of the Post as Shipment field.', Comment = '%';
                }
                field("Safe Entry No."; Rec."Safe Entry No.")
                {
                    ToolTip = 'Specifies the value of the Safe Entry No. field.', Comment = '%';
                }
                field("Safe Code"; Rec."Safe Code")
                {
                    ToolTip = 'Specifies the value of the Safe Code field.', Comment = '%';
                }
                field("Statement No."; Rec."Statement No.")
                {
                    ToolTip = 'Specifies the value of the Statement No. field.', Comment = '%';
                }
                field("Posting Status"; Rec."Posting Status")
                {
                    ToolTip = 'Specifies the value of the Posting Status field.', Comment = '%';
                }
                field("Posted Statement No."; Rec."Posted Statement No.")
                {
                    ToolTip = 'Specifies the value of the Posted Statement No. field.', Comment = '%';
                }
                field("Manager ID"; Rec."Manager ID")
                {
                    ToolTip = 'Specifies the value of the Manager ID field.', Comment = '%';
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the value of the Table No. field.', Comment = '%';
                }
                field("No. of Covers"; Rec."No. of Covers")
                {
                    ToolTip = 'Specifies the value of the No. of Covers field.', Comment = '%';
                }
                field("Split Number"; Rec."Split Number")
                {
                    ToolTip = 'Specifies the value of the Split Number field.', Comment = '%';
                }
                field(Comment; Rec.Comment)
                {
                    ToolTip = 'Specifies the value of the Comment field.', Comment = '%';
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ToolTip = 'Specifies the value of the Sell-to Contact No. field.', Comment = '%';
                }
                field("Gift Registration No."; Rec."Gift Registration No.")
                {
                    ToolTip = 'Specifies the value of the Gift Registration No. field.', Comment = '%';
                }
                field("Member Card No."; Rec."Member Card No.")
                {
                    ToolTip = 'Specifies the value of the Member Card No. field.', Comment = '%';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ToolTip = 'Specifies the value of the Sales Type field.', Comment = '%';
                }
                field("Starting Point Balance"; Rec."Starting Point Balance")
                {
                    ToolTip = 'Specifies the value of the Starting Point Balance field.', Comment = '%';
                }

                field("Retrieved from Suspended Trans"; Rec."Retrieved from Suspended Trans")
                {
                    ToolTip = 'Specifies the value of the Retrieved from Suspended Transaction field.', Comment = '%';
                }
                field("Apply to Doc. No."; Rec."Apply to Doc. No.")
                {
                    ToolTip = 'Specifies the value of the Apply to Doc. No. field.', Comment = '%';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Source Type field.', Comment = '%';
                }
                field("Open Drawer"; Rec."Open Drawer")
                {
                    ToolTip = 'Specifies the value of the Open Drawer field.', Comment = '%';
                }
                field(Replicated; Rec.Replicated)
                {
                    ToolTip = 'Specifies the value of the Replicated field.', Comment = '%';
                }
                field("Replication Counter"; Rec."Replication Counter")
                {
                    ToolTip = 'Specifies the value of the Replication Counter field.', Comment = '%';
                }
                field("Included in Statistics"; Rec."Included in Statistics")
                {
                    ToolTip = 'Specifies the value of the Included in Statistics field.', Comment = '%';
                }
                field("Retrieved from Receipt No."; Rec."Retrieved from Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Retrieved from Receipt No. field.', Comment = '%';
                }
                field("Z-Report ID"; Rec."Z-Report ID")
                {
                    ToolTip = 'Specifies the value of the Z-Report ID field.', Comment = '%';
                }
                field("Y-Report ID"; Rec."Y-Report ID")
                {
                    ToolTip = 'Specifies the value of the Y-Report ID field.', Comment = '%';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ToolTip = 'Specifies the value of the Tax Area Code field.', Comment = '%';
                }
                field("WIC Transaction"; Rec."WIC Transaction")
                {
                    ToolTip = 'Specifies the value of the WIC Transaction field.', Comment = '%';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ToolTip = 'Specifies the value of the Tax Liable field.', Comment = '%';
                }
                field("Tax Exemption No."; Rec."Tax Exemption No.")
                {
                    ToolTip = 'Specifies the value of the Tax Exemption No. field.', Comment = '%';
                }
                field("Net Income/Exp. Amount"; Rec."Net Income/Exp. Amount")
                {
                    ToolTip = 'Specifies the value of the Net Income/Exp. Amount field.', Comment = '%';
                }
                field("No. of Recomm. Calls"; Rec."No. of Recomm. Calls")
                {
                    ToolTip = 'Specifies the value of the No. of Recomm. Calls field.', Comment = '%';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Invoice No. field.', Comment = '%';
                }
                field("Transaction Code Type"; Rec."Transaction Code Type")
                {
                    ToolTip = 'Specifies the value of the Transaction Code Type field.', Comment = '%';
                }
                field("Cashier Report ID"; Rec."Cashier Report ID")
                {
                    ToolTip = 'Specifies the value of the Cashier Report ID field.', Comment = '%';
                }
                field("WHT Amount"; Rec."WHT Amount")
                {
                    ToolTip = 'Specifies the value of the WHT Amount field.', Comment = '%';
                }
                field("VAT Withholding"; Rec."VAT Withholding")
                {
                    ToolTip = 'Specifies the value of the VAT Withholding field.', Comment = '%';
                }
                field("Total VAT Amount"; Rec."Total VAT Amount")
                {
                    ToolTip = 'Specifies the value of the Total VAT Amount field.', Comment = '%';
                }
                field("Total Net Amount"; Rec."Total Net Amount")
                {
                    ToolTip = 'Specifies the value of the Total Net Amount field.', Comment = '%';
                }
                field("Identification Number"; Rec."Identification Number")
                {
                    ToolTip = 'Specifies the value of the Identification Number field.', Comment = '%';
                }
                field("Customer Type"; Rec."Customer Type")
                {
                    ToolTip = 'Specifies the value of the Customer Type field.', Comment = '%';
                }
                field("Beginning Balance"; Rec."Beginning Balance")
                {
                    ToolTip = 'Specifies the value of the Beginning Balance field.', Comment = '%';
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    ToolTip = 'Specifies the value of the Current Balance field.', Comment = '%';
                }
                field("Amount Before"; Rec."Amount Before")
                {
                    ToolTip = 'Specifies the value of the Amount Before field.', Comment = '%';
                }
                field("ZRWHT Amount"; Rec."ZRWHT Amount")
                {
                    ToolTip = 'Specifies the value of the ZRWHT Amount field.', Comment = '%';
                }
                field("Zero Rated Amount"; Rec."Zero Rated Amount")
                {
                    ToolTip = 'Specifies the value of the Zero Rated Amount field.', Comment = '%';
                }
                field("Customer Order ID"; Rec."Customer Order ID")
                {
                    ToolTip = 'Specifies the value of the Customer Order ID field.', Comment = '%';
                }
                field("Playback Recording ID"; Rec."Playback Recording ID")
                {
                    ToolTip = 'Specifies the value of the Playback Recording ID field.', Comment = '%';
                }
                field("Playback Entry No."; Rec."Playback Entry No.")
                {
                    ToolTip = 'Specifies the value of the Playback Entry No. field.', Comment = '%';
                }
                field("Customer Order"; Rec."Customer Order")
                {
                    ToolTip = 'Specifies the value of the Customer Order field.', Comment = '%';
                }
                field("PLB Item"; Rec."PLB Item")
                {
                    ToolTip = 'Specifies the value of the PLB Item field.', Comment = '%';
                }
                field("Override PLB Item"; Rec."Override PLB Item")
                {
                    ToolTip = 'Specifies the value of the Override PLB Item field.', Comment = '%';
                }
                field("Override Staff ID"; Rec."Override Staff ID")
                {
                    ToolTip = 'Specifies the value of the Override Staff ID field.', Comment = '%';
                }
                field("Override Date Time"; Rec."Override Date Time")
                {
                    ToolTip = 'Specifies the value of the Override Date Time field.', Comment = '%';
                }
                field(RestrictedFlag; Rec.RestrictedFlag)
                {
                    ToolTip = 'Specifies the value of the Restricted Flag field.', Comment = '%';
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
