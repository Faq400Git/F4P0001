        //-------------------------------------
        // This program will invoke a SOAP webservice
        // through a service program generated
        // with WSDL2RPG.SH utility:
        // STRQSH
        // /QIBM/ProdData/OS/WebServices/V1/client/BIN/wsdl2rpg.sh
        // -t90 -o/home/faq400/converttemp
        // -s/QSYS.LIB/FAQ400.LIB/convt.SRVPGM
        // http://xxx.xxx.xxx.xxx:port/web/services/ConvertTempService/ConvertTemp?wsdl
        //
        // Then I added this service program to my Bind Directory
        // ADDBNDDIRE BNDDIR(FAQ400/FAQ400SRV) OBJ((CONVT))
        //
        // Now I set my BNDDIR in ctl-opt
        // --------------------------------------------------------------------

        ctl-opt DFTNAME(F4WSDL01);
        ctl-opt BNDDIR('FAQ400SRV');

        /copy /home/faq400/ConvertTemp/ConvertTempServices.rpgleinc

        dcl-s  OutputText char(50);
        dcl-ds WsStub likeds(This_t);
        dcl-ds Input     likeds(CONVERTTEMPInput_t);
        dcl-ds Result    likeds(CONVERTTEMPResult_t) ;

        // *entry plist Temperature IN
        dcl-pi main extpgm('F4WSDL01');
          tempin char(32);
        END-PI;

       //--------------------------------------------------------------------
       // Web service logic. The code will attempt to invoke a Web
       // service in order to convert temperature in Fahrenheit to Celsius
       //and then display the results.
       //--------------------------------------------------------------------

         // Get a Web service stub. The host and port for the endpoint may need
         // to be changed to match host and port of Web service. Or you can pass
         // blanks and endpoint in the WSDL file will be used.
         clear WsStub;
         WsStub.endpoint =
         'http://172.17.238.46:10010'+
         '/web/services/ConvertTempService/ConvertTemp';
         clear input;
         Input.TEMPIN.value = %trim(TEMPIN);
         if (stub_create_ConvertTempServices(WsStub) = *ON);
           // Invoke the ConvertTemp Web service operation.
           if (stub_op_ConvertTemp0(WsStub:Input:Result) = *ON);
              OutputText = Input.TEMPIN.value + ' Fahrenheit is '
                         + Result.TEMPOUT.value + ' Celsius.';
           else;
              OutputText = WsStub.excString;
           endif;

           // Display results.
           dsply OutputText;

           // Destroy Web service stubs.
           stub_destroy_ConvertTempServices(WsStub);
         endif;

         *INLR=*ON;
         return;

