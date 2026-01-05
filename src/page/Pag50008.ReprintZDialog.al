page 50008 ReprintZDialog
{
    ApplicationArea = All;
    Caption = 'Reprint Z';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(StartDate; StartDate)
            {
                ApplicationArea = All;
                Caption = 'Start Date';
            }
            field(EndDate; EndDate)
            {
                ApplicationArea = All;
                Caption = 'End Date';
            }
        }
    }

    var
        StartDate: Date;
        EndDate: Date;

    procedure GetStartDate(): Date
    begin
        exit(StartDate);
    end;

    procedure GetEndDate(): Date
    begin
        exit(EndDate);
    end;
}
