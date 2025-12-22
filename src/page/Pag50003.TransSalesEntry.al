page 50003 "Trans. Sales Entry"
{
    ApplicationArea = All;
    Caption = 'AP Trans. Sales Entry';
    PageType = List;
    SourceTable = "LSC Trans. Sales Entry";
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
                field("Barcode No."; Rec."Barcode No.")
                {
                    ToolTip = 'Specifies the value of the Barcode No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Sales Staff"; Rec."Sales Staff")
                {
                    ToolTip = 'Specifies the value of the Sales Staff field.', Comment = '%';
                }
                field("Division Code"; Rec."Division Code")
                {
                    ToolTip = 'Specifies the value of the Division Code field.', Comment = '%';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Specifies the value of the Item Category Code field.', Comment = '%';
                }
                field("Retail Product Code"; Rec."Retail Product Code")
                {
                    ToolTip = 'Specifies the value of the Retail Product Code field.', Comment = '%';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the value of the Price field.', Comment = '%';
                }
                field("Net Price"; Rec."Net Price")
                {
                    ToolTip = 'Specifies the value of the Net Price field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Orig. Cost Price"; Rec."Orig. Cost Price")
                {
                    ToolTip = 'Specifies the value of the Orig. Cost Price field.', Comment = '%';
                }
                field("Price Group Code"; Rec."Price Group Code")
                {
                    ToolTip = 'Specifies the value of the Price Group Code field.', Comment = '%';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.', Comment = '%';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.', Comment = '%';
                }
                field("VAT Code"; Rec."VAT Code")
                {
                    ToolTip = 'Specifies the value of the VAT Code field.', Comment = '%';
                }
                field("xTransaction Status"; Rec."xTransaction Status")
                {
                    ToolTip = 'Specifies the value of the xTransaction Status field.', Comment = '%';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the value of the Discount % field.', Comment = '%';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Amount field.', Comment = '%';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ToolTip = 'Specifies the value of the Cost Amount field.', Comment = '%';
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
                field("Net Amount"; Rec."Net Amount")
                {
                    ToolTip = 'Specifies the value of the Net Amount field.', Comment = '%';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ToolTip = 'Specifies the value of the VAT Amount field.', Comment = '%';
                }
                field("Promotion No."; Rec."Promotion No.")
                {
                    ToolTip = 'Specifies the value of the Promotion No. field.', Comment = '%';
                }
                field("Standard Net Price"; Rec."Standard Net Price")
                {
                    ToolTip = 'Specifies the value of the Standard Net Price field.', Comment = '%';
                }
                field("Disc. Amount From Std. Price"; Rec."Disc. Amount From Std. Price")
                {
                    ToolTip = 'Specifies the value of the Disc. Amount From Std. Price field.', Comment = '%';
                }
                field("xStatement No."; Rec."xStatement No.")
                {
                    ToolTip = 'Specifies the value of the xStatement No. field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field(Section; Rec.Section)
                {
                    ToolTip = 'Specifies the value of the Section field.', Comment = '%';
                }
                field(Shelf; Rec.Shelf)
                {
                    ToolTip = 'Specifies the value of the Shelf field.', Comment = '%';
                }
                field("Statement Code"; Rec."Statement Code")
                {
                    ToolTip = 'Specifies the value of the Statement Code field.', Comment = '%';
                }
                field("Item Disc. Group"; Rec."Item Disc. Group")
                {
                    ToolTip = 'Specifies the value of the Item Disc. Group field.', Comment = '%';
                }
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ToolTip = 'Specifies the value of the Transaction Code field.', Comment = '%';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.', Comment = '%';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("Item Number Scanned"; Rec."Item Number Scanned")
                {
                    ToolTip = 'Specifies the value of the Item Number Scanned field.', Comment = '%';
                }
                field("Keyboard Item Entry"; Rec."Keyboard Item Entry")
                {
                    ToolTip = 'Specifies the value of the Keyboard Item Entry field.', Comment = '%';
                }
                field("Price in Barcode"; Rec."Price in Barcode")
                {
                    ToolTip = 'Specifies the value of the Price in Barcode field.', Comment = '%';
                }
                field("Price Change"; Rec."Price Change")
                {
                    ToolTip = 'Specifies the value of the Price Change field.', Comment = '%';
                }
                field("Weight Manually Entered"; Rec."Weight Manually Entered")
                {
                    ToolTip = 'Specifies the value of the Weight Manually Entered field.', Comment = '%';
                }
                field("Line was Discounted"; Rec."Line was Discounted")
                {
                    ToolTip = 'Specifies the value of the Line was Discounted field.', Comment = '%';
                }
                field("Scale Item"; Rec."Scale Item")
                {
                    ToolTip = 'Specifies the value of the Scale Item field.', Comment = '%';
                }
                field("Weight Item"; Rec."Weight Item")
                {
                    ToolTip = 'Specifies the value of the Weight Item field.', Comment = '%';
                }
                field("Return No Sale"; Rec."Return No Sale")
                {
                    ToolTip = 'Specifies the value of the Return No Sale field.', Comment = '%';
                }
                field("Item Corrected Line"; Rec."Item Corrected Line")
                {
                    ToolTip = 'Specifies the value of the Item Corrected Line field.', Comment = '%';
                }
                field("Type of Sale"; Rec."Type of Sale")
                {
                    ToolTip = 'Specifies the value of the Type of Sale field.', Comment = '%';
                }
                field("Linked No. not Orig."; Rec."Linked No. not Orig.")
                {
                    ToolTip = 'Specifies the value of the Linked No. not Orig. field.', Comment = '%';
                }
                field("Orig. of a Linked Item List"; Rec."Orig. of a Linked Item List")
                {
                    ToolTip = 'Specifies the value of the Orig. of a Linked Item List field.', Comment = '%';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.', Comment = '%';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ToolTip = 'Specifies the value of the Staff ID field.', Comment = '%';
                }
                field("Item Posting Group"; Rec."Item Posting Group")
                {
                    ToolTip = 'Specifies the value of the Item Posting Group field.', Comment = '%';
                }
                field("Total Rounded Amt."; Rec."Total Rounded Amt.")
                {
                    ToolTip = 'Specifies the value of the Total Rounded Amt. field.', Comment = '%';
                }
                field(Counter; Rec.Counter)
                {
                    ToolTip = 'Specifies the value of the Counter field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the value of the Serial No. field.', Comment = '%';
                }
                field("Serial/Lot No. Not Valid"; Rec."Serial/Lot No. Not Valid")
                {
                    ToolTip = 'Specifies the value of the Serial/Lot No. Not Valid field.', Comment = '%';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ToolTip = 'Specifies the value of the Lot No. field.', Comment = '%';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ToolTip = 'Specifies the value of the Expiration Date field.', Comment = '%';
                }
                field("Member Points Type"; Rec."Member Points Type")
                {
                    ToolTip = 'Specifies the value of the Member Points Type field.', Comment = '%';
                }
                field("Member Points"; Rec."Member Points")
                {
                    ToolTip = 'Specifies the value of the Member Points field.', Comment = '%';
                }
                field("Offer Blocked Points"; Rec."Offer Blocked Points")
                {
                    ToolTip = 'Specifies the value of the Offer Blocked Points field.', Comment = '%';
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Date field.', Comment = '%';
                }
                field("Trans. Time"; Rec."Trans. Time")
                {
                    ToolTip = 'Specifies the value of the Trans. Time field.', Comment = '%';
                }
                field("Posting Exception Key"; Rec."Posting Exception Key")
                {
                    ToolTip = 'Specifies the value of the Posting Exception Key field.', Comment = '%';
                }
                field("Line Discount"; Rec."Line Discount")
                {
                    ToolTip = 'Specifies the value of the Line Discount field.', Comment = '%';
                }
                field(Replicated; Rec.Replicated)
                {
                    ToolTip = 'Specifies the value of the Replicated field.', Comment = '%';
                }
                field("Customer Discount"; Rec."Customer Discount")
                {
                    ToolTip = 'Specifies the value of the Customer Discount field.', Comment = '%';
                }
                field("Infocode Discount"; Rec."Infocode Discount")
                {
                    ToolTip = 'Specifies the value of the Infocode Discount field.', Comment = '%';
                }
                field("Cust. Invoice Discount"; Rec."Cust. Invoice Discount")
                {
                    ToolTip = 'Specifies the value of the Cust. Invoice Discount field.', Comment = '%';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                }
                field("UOM Quantity"; Rec."UOM Quantity")
                {
                    ToolTip = 'Specifies the value of the UOM Quantity field.', Comment = '%';
                }
                field("UOM Price"; Rec."UOM Price")
                {
                    ToolTip = 'Specifies the value of the UOM Price field.', Comment = '%';
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    ToolTip = 'Specifies the value of the Total Discount field.', Comment = '%';
                }
                field("Total Disc.%"; Rec."Total Disc.%")
                {
                    ToolTip = 'Specifies the value of the Total Disc.% field.', Comment = '%';
                }
                field("Tot. Disc Info Line No."; Rec."Tot. Disc Info Line No.")
                {
                    ToolTip = 'Specifies the value of the Tot. Disc Info Line No. field.', Comment = '%';
                }
                field("Periodic Disc. Type"; Rec."Periodic Disc. Type")
                {
                    ToolTip = 'Specifies the value of the Periodic Disc. Type field.', Comment = '%';
                }
                field("Periodic Disc. Group"; Rec."Periodic Disc. Group")
                {
                    ToolTip = 'Specifies the value of the Periodic Disc. Group field.', Comment = '%';
                }
                field("Periodic Discount"; Rec."Periodic Discount")
                {
                    ToolTip = 'Specifies the value of the Periodic Discount field.', Comment = '%';
                }
                field("Deal Line"; Rec."Deal Line")
                {
                    ToolTip = 'Specifies the value of the Deal Line field.', Comment = '%';
                }
                field("Deal Header Line No."; Rec."Deal Header Line No.")
                {
                    ToolTip = 'Specifies the value of the Deal Header Line No. field.', Comment = '%';
                }
                field("Deal Line No."; Rec."Deal Line No.")
                {
                    ToolTip = 'Specifies the value of the Deal Line No. field.', Comment = '%';
                }
                field("Deal Line Added Amt."; Rec."Deal Line Added Amt.")
                {
                    ToolTip = 'Specifies the value of the Deal Line Added Amt. field.', Comment = '%';
                }
                field("Deal Modifier Added Amt."; Rec."Deal Modifier Added Amt.")
                {
                    ToolTip = 'Specifies the value of the Deal Modifier Added Amt. field.', Comment = '%';
                }
                field("Deal Modifier Line No."; Rec."Deal Modifier Line No.")
                {
                    ToolTip = 'Specifies the value of the Deal Modifier Line No. field.', Comment = '%';
                }
                field("Discount Amt. For Printing"; Rec."Discount Amt. For Printing")
                {
                    ToolTip = 'Specifies the value of the Discount Amt. For Printing field.', Comment = '%';
                }
                field("Coupon Discount"; Rec."Coupon Discount")
                {
                    ToolTip = 'Specifies the value of the Coupon Discount field.', Comment = '%';
                }
                field("Coupon Amt. For Printing"; Rec."Coupon Amt. For Printing")
                {
                    ToolTip = 'Specifies the value of the Coupon Amt. For Printing field.', Comment = '%';
                }
                field("Replication Counter"; Rec."Replication Counter")
                {
                    ToolTip = 'Specifies the value of the Replication Counter field.', Comment = '%';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ToolTip = 'Specifies the value of the Sales Type field.', Comment = '%';
                }
                field("Orig. from Infocode"; Rec."Orig. from Infocode")
                {
                    ToolTip = 'Specifies the value of the Orig. from Infocode field.', Comment = '%';
                }
                field("Orig. from Subcode"; Rec."Orig. from Subcode")
                {
                    ToolTip = 'Specifies the value of the Orig. from Subcode field.', Comment = '%';
                }
                field("Parent Line No."; Rec."Parent Line No.")
                {
                    ToolTip = 'Specifies the value of the Parent Line No. field.', Comment = '%';
                }
                field("Infocode Entry Line No."; Rec."Infocode Entry Line No.")
                {
                    ToolTip = 'Specifies the value of the Infocode Entry Line No. field.', Comment = '%';
                }
                field("Excluded BOM Line No."; Rec."Excluded BOM Line No.")
                {
                    ToolTip = 'Specifies the value of the Excluded BOM Line No. field.', Comment = '%';
                }
                field("Infocode Selected Qty."; Rec."Infocode Selected Qty.")
                {
                    ToolTip = 'Specifies the value of the Infocode Selected Qty. field.', Comment = '%';
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';
                }
                field("Orig Trans Store"; Rec."Orig Trans Store")
                {
                    ToolTip = 'Specifies the value of the Orig. Trans. Store field.', Comment = '%';
                }
                field("Orig Trans Pos"; Rec."Orig Trans Pos")
                {
                    ToolTip = 'Specifies the value of the Orig. Trans. Pos field.', Comment = '%';
                }
                field("Orig Trans No."; Rec."Orig Trans No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Trans. No. field.', Comment = '%';
                }
                field("Orig Trans Line No."; Rec."Orig Trans Line No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Trans. Line No. field.', Comment = '%';
                }
                field("Refund Qty."; Rec."Refund Qty.")
                {
                    ToolTip = 'Specifies the value of the Refund Qty. field.', Comment = '%';
                }
                field("Refunded Line No."; Rec."Refunded Line No.")
                {
                    ToolTip = 'Specifies the value of the Refunded Line No. field.', Comment = '%';
                }
                field("Refunded Trans. No."; Rec."Refunded Trans. No.")
                {
                    ToolTip = 'Specifies the value of the Refunded Trans. No. field.', Comment = '%';
                }
                field("Refunded POS No."; Rec."Refunded POS No.")
                {
                    ToolTip = 'Specifies the value of the Refunded POS No. field.', Comment = '%';
                }
                field("Refunded Store No."; Rec."Refunded Store No.")
                {
                    ToolTip = 'Specifies the value of the Refunded Store No. field.', Comment = '%';
                }
                field("Created by Staff ID"; Rec."Created by Staff ID")
                {
                    ToolTip = 'Specifies the value of the Created by Staff ID field.', Comment = '%';
                }
                field("Marked for Gift Receipt"; Rec."Marked for Gift Receipt")
                {
                    ToolTip = 'Specifies the value of the Marked for Gift Receipt field.', Comment = '%';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the value of the Line Type Extension field.', Comment = '%';
                }
                field("Package Parent Line No."; Rec."Package Parent Line No.")
                {
                    ToolTip = 'Specifies the value of the Package Parent Line No. field.', Comment = '%';
                }

                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ToolTip = 'Specifies the value of the Tax Calculation Type field.', Comment = '%';
                }
                field("Sales Tax Rounding"; Rec."Sales Tax Rounding")
                {
                    ToolTip = 'Specifies the value of the Sales Tax Rounding field.', Comment = '%';
                }
                field("Tax Group Code 2"; Rec."Tax Group Code 2")
                {
                    ToolTip = 'Specifies the value of the Tax Group Code field.', Comment = '%';
                }
                field("Local VAT Code"; Rec."Local VAT Code")
                {
                    ToolTip = 'Specifies the value of the Local VAT Code field.', Comment = '%';
                }
                field("Item Disc. % Orig."; Rec."Item Disc. % Orig.")
                {
                    ToolTip = 'Specifies the value of the Item Disc. % Orig. field.', Comment = '%';
                }
                field("Item Disc. % Actual"; Rec."Item Disc. % Actual")
                {
                    ToolTip = 'Specifies the value of the Item Disc. % Actual field.', Comment = '%';
                }
                field("Item Disc. Type"; Rec."Item Disc. Type")
                {
                    ToolTip = 'Specifies the value of the Item Disc. Type field.', Comment = '%';
                }
                field("Recommended Item"; Rec."Recommended Item")
                {
                    ToolTip = 'Specifies the value of the Recommended Item field.', Comment = '%';
                }
                field("System-Exclude From Print"; Rec."System-Exclude From Print")
                {
                    ToolTip = 'Specifies the value of the System-Exclude From Print field.', Comment = '%';
                }
                field("Reduced Quantity"; Rec."Reduced Quantity")
                {
                    ToolTip = 'Specifies the value of the Reduced Quatity field.', Comment = '%';
                }
                field("PLB Item"; Rec."PLB Item")
                {
                    ToolTip = 'Specifies the value of the PLB Item field.', Comment = '%';
                }
                field(Limitation; Rec.Limitation)
                {
                    ToolTip = 'Specifies the value of the EBT field.', Comment = '%';
                }
                field("Limitation Tax Exempted"; Rec."Limitation Tax Exempted")
                {
                    ToolTip = 'Specifies the value of the Limitation Tax Exempted field.', Comment = '%';
                }
                field(EBTCash; Rec.EBTCash)
                {
                    ToolTip = 'Specifies the value of the EBTCash field.', Comment = '%';
                }
                field("EBTCash Tax Exempted"; Rec."EBTCash Tax Exempted")
                {
                    ToolTip = 'Specifies the value of the EBTCash Tax Exempted field.', Comment = '%';
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
