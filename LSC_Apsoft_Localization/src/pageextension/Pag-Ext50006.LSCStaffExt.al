pageextension 50007 "LSC STAFF Card Ext" extends "LSC STAFF Staff Card"
{
    layout
    {
        addlast(General)
        {
            field("Last X-Report"; Rec."Last X-Report")
            {
                Caption = 'Last X-Report';
                ApplicationArea = All;
            }
        }
    }
}