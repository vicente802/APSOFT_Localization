enum 50000 "BLOB File Types"
{
    /*
    REFERENCE:
    Overcoming File Management limitations in SaaS using BlobStorages  By:  Mark Soriano (Dynamics NAV / 365 BC Developer)
    */

    Extensible = true;

    value(0; Folder)
    {
        Caption = 'Folder';
    }
    value(1; "File")
    {
        Caption = 'File';
    }

}