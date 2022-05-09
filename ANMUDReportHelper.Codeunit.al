codeunit 50003 "ANMUD Report Helper"
{

    trigger OnRun()
    begin
    end;

    var
        ExcelReportBuilderManager: Codeunit "14930";
        StdRepMgt: Codeunit "12401";
        LocMgt: Codeunit "12400";
        LastTotalAmount: array[6] of Decimal;
        TotalAmount: array[6] of Decimal;
        PrevDocPageNo: Integer;
        DocumentNo: Text;
        PageHeaderCurrencyText: Text;

    [Scope('Internal')]
    procedure InitReportTemplate()
    var
        SalesReceivablesSetup: Record "311";
    begin
        SalesReceivablesSetup.GET;
        SalesReceivablesSetup.TESTFIELD("ANMUD Sales Template Code");
        ExcelReportBuilderManager.InitTemplate(SalesReceivablesSetup."ANMUD Sales Template Code");
        ExcelReportBuilderManager.SetSheet('Лист1');
    end;

    [Scope('Internal')]
    procedure IncreaseTotals(AmountValues: array[6] of Decimal)
    var
        I: Integer;
    begin
        FOR I := 1 TO 6 DO
            TotalAmount[I] += AmountValues[I];
    end;

    [Scope('Internal')]
    procedure SaveLastTotals()
    var
        I: Integer;
    begin
        FOR I := 1 TO 6 DO
            LastTotalAmount[I] := TotalAmount[I];
    end;

    [Scope('Internal')]
    procedure FillHeader(HeaderDetails: array[6] of Text)
    begin
        CLEAR(TotalAmount);
        CLEAR(LastTotalAmount);

        ExcelReportBuilderManager.AddSection('Header');

        ExcelReportBuilderManager.AddDataToSection('Company_Name', HeaderDetails[1]);
        ExcelReportBuilderManager.AddDataToSection('Address', HeaderDetails[2]);
        ExcelReportBuilderManager.AddDataToSection('Registration_No', HeaderDetails[3]);
        ExcelReportBuilderManager.AddDataToSection('Customer_Name', HeaderDetails[4]);
        ExcelReportBuilderManager.AddDataToSection('Delivery_address', HeaderDetails[5]);
        ExcelReportBuilderManager.AddDataToSection('Customer_Phone_No', HeaderDetails[6]);
    end;

    [Scope('Internal')]
    procedure FillPageHeader()
    begin
        ExcelReportBuilderManager.AddSection('Lines_Caption');
    end;

    [Scope('Internal')]
    procedure FillLine(BodyDetails: array[8] of Text; AmountValues: array[6] of Decimal)
    begin
        ExcelReportBuilderManager.AddSection('Body');
        IncreaseTotals(AmountValues);

        ExcelReportBuilderManager.AddDataToSection('Item_No', BodyDetails[1]);
        ExcelReportBuilderManager.AddDataToSection('Description', BodyDetails[2]);
        ExcelReportBuilderManager.AddDataToSection('Quantity', BodyDetails[3]);
        ExcelReportBuilderManager.AddDataToSection('Unit_Price', BodyDetails[4]);
        ExcelReportBuilderManager.AddDataToSection('Amount', BodyDetails[5]);
        ExcelReportBuilderManager.AddDataToSection('Total_Amount', BodyDetails[6]);
        ExcelReportBuilderManager.AddDataToSection('Total_VAT_Amount', BodyDetails[7]);
        ExcelReportBuilderManager.AddDataToSection('Amount_Including_VAT', BodyDetails[8]);
    end;

    [Scope('Internal')]
    procedure FillPageFooter()
    begin
        ExcelReportBuilderManager.AddSection('Footer');

        ExcelReportBuilderManager.AddDataToSection(
         'Total_Amount', StdRepMgt.FormatReportValue(TotalAmount[1] - LastTotalAmount[1], 2));
        ExcelReportBuilderManager.AddDataToSection(
         'Total_VAT_Amount', StdRepMgt.FormatReportValue(TotalAmount[2] - LastTotalAmount[2], 2));
        ExcelReportBuilderManager.AddDataToSection(
         'Amount_Including_VAT', StdRepMgt.FormatReportValue(TotalAmount[3] - LastTotalAmount[3], 2));

        SaveLastTotals;
    end;

    [Scope('Internal')]
    procedure FinishDocument()
    begin

        PrevDocPageNo := ExcelReportBuilderManager.GetLastPageNo;
        ExcelReportBuilderManager.AddPagebreak;
    end;

    [Scope('Internal')]
    procedure ExportData()
    begin
        ExcelReportBuilderManager.ExportData;
    end;

    [Scope('Internal')]
    procedure ExportDataToClientFile(FileName: Text)
    begin
        ExcelReportBuilderManager.ExportDataToClientFile(FileName);
    end;
}

