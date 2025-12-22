tableextension 50016 "CustomerDiscountGroupExt" extends "Customer Discount Group"
{
    fields
    {
        field(90001; "Infocode Discount Group"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(90002; "Discount Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Promo/Regular Discount","Employee Discount","Senior Citizen Discount","VIP Discount","PWD Discount","GPC Discount",DISC1,DISC2,DISC3,DISC4,DISC5,DISC6;
        }
    }
    trigger OnBeforeInsert()
    begin
        Rec."Infocode Discount Group" := true;
    end;

}