       //-----------------------------------------
       // F4XMLPARS1 SQLRPGLE Source
       //   We are trying to parse and XML stored
       //   in our IFS, and extract data from
       //   different levels and  different namespaces
       //   through XMLTABLE and XMLPARSE SQL Function
       //
       //   Pay attention to GET_XML_FILE to read an xml
       //   stored in the IFS
       //
       //   Rev. 5
       // ------------------------------------------------
       ctl-opt DFTACTGRP(*NO);




       dcl-ds dsresult qualified dim(999);
         totalrecords packed(9:0);
         pagesize packed(9:0);
         totalpages packed(9:0);
         pageindex packed(9:0);
         searchid varchar(50);
         displayname varchar(50);
         internalid varchar(50);
         itemid varchar(50);
         saleunit varchar(50);
         type varchar(50);
         weight varchar(50);
       end-ds;




       dcl-s  risposta char(10);

       dcl-s  RowsFetched int(5);
       dcl-s  i           int(5);


       // Set COMMIT to read XML file from IFS
       exec sql SET OPTION COMMIT=*CHG;

       // Set CCSID for some HTTP Functions (65535 is no good!)
       exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(280)');


       // Get my XML file from IFS and parse it with  XMLTABLE
       // and XMLPARSE SQL Functions
       exec sql
        declare wscursor cursor for
        select *
        FROM
        XMLTABLE(
        xmlnamespaces
        (default 'urn:core_2018_1.platform.webservices.netsuite.com',
         'http://schemas.xmlsoap.org/soap/envelope/' AS "soap",
         'urn:accounting_2018_1.lists.webservices.netsuite.com' as "listact",
         'urn:common_2018_1.platform.webservices.netsuite.com' as "platf"
            ),
          '$doc/soap:Envelope/soap:Body/+
          *:searchResponse/searchResult/+
          *:searchRowList/searchRow[*]'
       PASSING
       xmlparse(document GET_XML_FILE('/tmp/NetSuite XML SOAP Response.xml'))
       as "doc"
       columns
       totalRecords decimal(9, 0) path '../../totalRecords',
       pageSize decimal(9, 0) path '../../pageSize',
       totalPages decimal(9, 0) path '../../totalPages',
       pageIndex decimal(9, 0) path '../../pageIndex',
       searchId varchar(50) path '../../searchId',
       displayName varchar(50) path '*:basic/*:displayName/searchValue',
       internalId varchar(50)
         path '*:basic/*:internalId/searchValue/@internalId',
       itemId varchar(50) path '*:basic/*:itemId/searchValue',
       saleUnit varchar(50) path '*:basic/*:saleUnit/searchValue/@internalId',
       type varchar(50) path '*:basic/*:type/searchValue',
       weight varchar(50) path '*:basic/*:weight/searchValue'
       ) as a;

       exec sql open wscursor;

       exec sql
          fetch wscursor for 999 rows into :dsresult;

       exec sql GET DIAGNOSTICS :RowsFetched = ROW_COUNT ;

       // Return to my current job CCSID
       exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(*USRPRF)');

       dsply 'Risultato:';
       for i=1 to RowsFetched;
          dsply 'Row :';
          dsply i;
          dsply '- displayname:';
          dsply dsresult(i).displayname;
          dsply '- internalid:';
          dsply dsresult(i).internalid;
          dsply '- itemid:';
          dsply dsresult(i).itemid;
          dsply '- weight:';
          dsply dsresult(i).weight;
       endfor;
       dsply 'End' '' risposta;


       *inlr=*on;


