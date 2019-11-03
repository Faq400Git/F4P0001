       //-------------------------------------------------------
       // F4HTTPAPI: Consuming a SOAP web service
       //      through HTTPAPI utility by Scott Klement
       //
       //  Version 1.0
       // -------------------------------------------------

        ctl-opt option(*srcstmt:*nounref) dftactgrp(*no);
        ctl-opt BNDDIR('HTTPAPI') ;

        // Entry plist
        dcl-pi F4HTTPAPI1;
           TempinAlfa char(15);
        END-PI;


        /copy httpapi_h

        dcl-s UrlHost       varchar(200);
        dcl-s UrlEndPoint   varchar(200);
        dcl-s PostUrl       varchar(254);
        dcl-s PostData      varchar(32000) ;
        dcl-s PostResult    varchar(32000) ;
        dcl-s string char(30);
        dcl-s reply  char(10);
        dcl-s errorMsg char(256);

        // Input data
        dcl-s tempin packed(7:2);

        // Output data
        dcl-ds xmlout qualified;
             Tempout packed(7:2);
        END-DS;


        // Set CCSID 280 (ITA)
         exec sql
          CALL QSYS2.QCMDEXC('CHGJOB CCSID(280)');

        // Legge input
        monitor;
           tempin=%dec(tempinAlfa:7:2);
        on-error;
           tempin=40;
        ENDMON;

        UrlHost       ='http://172.17.238.46:10010';
        UrlEndPoint='/web/services/ConvertTempService/ConvertTemp';

        PostUrl=%trim(UrlHost)+%trim(UrlEndPoint);
        PostData=set_PostdataConvertTemp(Tempin);
        //PostHeader=get_PostHeader(%len(%trim(PostData)):'text/xml');

        // Call the SOAP web service
        // http_setOption('SoapAction': '"GetConversionRate"');
        clear errorMsg;
        clear xmlout;

        monitor;
          PostResult = http_string( 'POST': PostURL: PostData: 'text/xml');
        on-error;
          ErrorMsg=http_error();
          PostResult='<Result>Error</Result>';
        endmon;

        // Parse output
        monitor;
          xml-into xmlout %xml(postResult: 'case=any ns=remove +
             path=Envelope/Body/converttempResponse/return');
        on-error;
        endmon;

        // Reimposta CCSID predefinito dell'utente
         exec sql
          CALL QSYS2.QCMDEXC('CHGJOB CCSID(*USRPRF)');


        string='Tempin:'+%editc(tempin:'K');
        dsply string;
        string='Tempout:'+%editc(xmlout.tempout:'K');
        dsply string ;
        Dsply ( 'Press <Enter> to end program' ) ' ' reply;

        *inlr = *on ;


        //-------------------------------------------------------
        // Set Postdata ... SOAP Envelope
        //-------------------------------------------------------
        dcl-proc set_PostDataConvertTemp;
        dcl-pi   set_PostDataConvertTemp varchar(32000);
          TempF   packed(7:2) const;
        end-pi;
        dcl-s PostData varchar(32000);

        PostData=' '
        +'<soapenv:Envelope'
        +' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
        +' xmlns:con="http://converttemp.wsbeans.iseries/">'
        +' <soapenv:Header/>'
        +'    <soapenv:Body>'
        +'      <con:converttemp>'
        +'         <arg0>'
        +'            <TEMPIN>$$TEMPF</TEMPIN>'
        +'         </arg0>'
        +'      </con:converttemp>'
        +'   </soapenv:Body>'
        +'</soapenv:Envelope>';

        // Set input temperature;
        PostData=%scanrpl('$$TEMPF':%editc(Tempf:'K'):PostData);

        return PostData;
       end-proc;


