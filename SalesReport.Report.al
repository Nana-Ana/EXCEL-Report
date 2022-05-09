report 50001 "Sales Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SalesReport.rdlc';

    dataset
    {
        dataitem(Header; Table36)
        {
            DataItemTableView = SORTING (No.);
            RequestFilterFields = "No.";
            dataitem(Line; Table37)
            {
                DataItemLink = Document Type=FIELD(Document Type),
                               Document No.=FIELD(No.);
                DataItemTableView = SORTING(Document Type,Document No.,Line No.)
                                    ORDER(Ascending);

                trigger OnAfterGetRecord()
                var
                    AmountValues: array [6] of Decimal;
                begin

                    TransferBodyValues(AmountValues);
                end;

                trigger OnPostDataItem()
                var
                    AmountValues: array [3] of Decimal;
                begin
                      IF AtLeastOneLineExists THEN
                       TransferFooterValues;
                      TransferAmounts(AmountValues);
                    // //SalesReportHelper.FillPageFooter;
                end;

                trigger OnPreDataItem()
                begin

                    //SalesReportHelper.FillPageHeader;
                    ANMUDReportHelper.FillPageHeader;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                 CompanyInfo.GET;

                TransferHeaderValues;
            end;

            trigger OnPreDataItem()
            begin
                SalesSetup.GET;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        IF ReportFileName = '' THEN
          ANMUDReportHelper.ExportData
        ELSE
          ANMUDReportHelper.ExportDataToClientFile(ReportFileName);
    end;

    trigger OnPreReport()
    begin
         IF NOT CurrReport.USEREQUESTPAGE THEN
          CopiesNumber := 1;

        //SalesReportHelper.InitReportTemplate;
        ANMUDReportHelper.InitReportTemplate;
    end;

    var
        SalesReportHelper: Codeunit "50000";
        ReportFileName: Text;
        SalesSetup: Record "311";
        CompanyInfo: Record "79";
        Cust: Record "18";
        Preview: Boolean;
        CopiesNumber: Integer;
        StdRepMgt: Codeunit "12401";
        AtLeastOneLineExists: Boolean;
        SalesHeader: Record "36";
        ANMUDReportHelper: Codeunit "50003";

    [Scope('Internal')]
    procedure TransferHeaderValues()
    var
        HeaderDetails: array [6] of Text;
    begin
        // HeaderDetails[1] := CompanyInfo.Name;
        // HeaderDetails[2] := CompanyInfo.Address;
        // HeaderDetails[3] := CompanyInfo."Registration No.";
        // HeaderDetails[4] := Cust.Name;
        // HeaderDetails[5] := Cust.Address;
        // HeaderDetails[6] := Cust."Phone No.";


        HeaderDetails[1] := StdRepMgt.GetCompanyName;
        HeaderDetails[2] := StdRepMgt.GetCompanyAddress;
        HeaderDetails[3] := CompanyInfo."Registration No.";
        HeaderDetails[4] := Header."Sell-to Customer Name";
        HeaderDetails[5] := Header."Sell-to Address";
        HeaderDetails[6] := Header."Sell-to Phone No.";

        ANMUDReportHelper.FillHeader(HeaderDetails);
    end;

    [Scope('Internal')]
    procedure TransferBodyValues(AmountValues: array [6] of Decimal)
    var
        BodyDetails: array [8] of Text;
    begin

         IF Line.Type <> Line.Type::" " THEN BEGIN
          BodyDetails[1] := Line."No.";
          BodyDetails[2] := Line.Description;
          BodyDetails[3] := FORMAT(Line.Quantity);
          BodyDetails[4] := StdRepMgt.FormatReportValue(Line."Unit Price",2);
          BodyDetails[5] := StdRepMgt.FormatReportValue(Line."Amount Including VAT",2);

          AmountValues[1] := Line.Amount;
          AmountValues[2] := Line."Amount Including VAT" - Line.Amount; ///////
          AmountValues[3] := Line."Amount Including VAT";
          ANMUDReportHelper.FillLine(BodyDetails,AmountValues);
         END;
    end;

    [Scope('Internal')]
    procedure TransferAmounts(AmountValues: array [3] of Decimal)
    begin
         WITH Line DO BEGIN
          AmountValues[1] := Amount;
          AmountValues[2] := "Amount Including VAT" - Amount;
          AmountValues[3] := "Amount Including VAT";
          ANMUDReportHelper.FillPageFooter();
         END;
    end;

    [Scope('Internal')]
    procedure TransferFooterValues()
    begin
        ANMUDReportHelper.FinishDocument;
    end;

    [Scope('Internal')]
    procedure InitializeRequest(FileName: Text;NewPreview: Boolean)
    begin
        ReportFileName := FileName;
        Preview := NewPreview;
    end;
}

