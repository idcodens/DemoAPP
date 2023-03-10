unit uDemo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  REST.Client, REST.Authenticator.Basic, FMX.StdCtrls, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.Edit, FMX.Controls.Presentation,system.JSON,
  System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.Memo.Types, FMX.Memo,
  strUtils, FMX.DateTimeCtrls, FMX.TabControl;

type
  TfrmDemo = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Panel1: TPanel;
    edtFilter: TEdit;
    btnPretragaArtikli: TButton;
    gridArtikli: TGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    Panel2: TPanel;
    btnPretragaObrTab2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    DatumOdTab2: TDateEdit;
    DatumDoTab2: TDateEdit;
    gridObracunTab2: TGrid;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumn7: TStringColumn;
    banPJTab2: TEdit;
    Label3: TLabel;
    Panel3: TPanel;
    btnClose: TButton;
    Panel4: TPanel;
    btnPretragaObrTab3: TButton;
    Label4: TLabel;
    Label5: TLabel;
    DatumOdTab3: TDateEdit;
    DatumDoTab3: TDateEdit;
    banPJTab3: TEdit;
    Label6: TLabel;
    GridObracunTab3: TGrid;
    StringColumn8: TStringColumn;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    StringColumn11: TStringColumn;
    StringColumn12: TStringColumn;
    procedure btnPretragaArtikliClick(Sender: TObject);
    procedure btnPretragaObrTab2Click(Sender: TObject);
    procedure gridArtikliGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure btnCloseClick(Sender: TObject);
    procedure gridObracunTab2GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure btnPretragaObrTab3Click(Sender: TObject);
    procedure GridObracunTab3GetValue(Sender: TObject; const ACol,
      ARow: Integer; var Value: TValue);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDemo: TfrmDemo;
  niz:Tarray<string>;
  x:array of array of string;
  y:array of array of string;
  z:array of array of string;


implementation

{$R *.fmx}

procedure TfrmDemo.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrmDemo.btnPretragaArtikliClick(Sender: TObject);
var
 JSonArray:TJSonArray;
 JSonValue :TJSonValue;
 id,naziv,st: string;
 ArrayElement: TJSonValue;
 FoundValue: TJSonValue;
 p,i,j:integer;

begin


 gridArtikli.BeginUpdate;


  try
   restClient1.baseurl:= 'http://apidemo.luceed.hr/datasnap/rest/artikli/naziv';
   restRequest1.Execute;
  except
       showmessage('Gre?ka prilikom konekcije na web servis');
       exit;
  end;


  // priprema JSON odogvora
  JSonValue:= restresponse1.JSONValue;
  JsonValue:=(JsonValue as TJSONObject).Get('result').JSONValue;


   st:=  rightstr(JsonValue.ToString,length(JsonValue.ToString)-1);
   st:=  leftStr (st,length(JsonValue.ToString)-2);

   JsonValue := TJSonObject.ParseJSONValue(st);
   JsonArray := JsonValue.GetValue<TJSONArray>('artikli');


  // inicijalizacija pomocnog niza y //
   i:=0;

   for ArrayElement in JsonArray do begin
      FoundValue := ArrayElement.FindValue('id');
      if FoundValue <> nil then
       i:=i+1 ;
   end;

     FillChar(y, SizeOf(y), 0);
     SetLength(y, i, 2);



   // punjenje niza y  //

   i:=0;

  // pretraga artikala po nazivu
  if edtFilter.text = '' then
  begin

    for ArrayElement in JsonArray do begin
       FoundValue := ArrayElement.FindValue('id');
        if FoundValue <> nil then begin
         naziv := ArrayElement.GetValue<string>('naziv');
         id := ArrayElement.GetValue<string>('id');

         y[i,0]:= id;
         y[i,1]:= naziv;

          i:= i+1;
       end;
    end;
  end
  else     // prikaz svih artikala
   begin

   for ArrayElement in JsonArray do begin
       FoundValue := ArrayElement.FindValue('id');
       if FoundValue <> nil then begin
         naziv := ArrayElement.GetValue<string>('naziv');
         id := ArrayElement.GetValue<string>('id');

         // uporedjivanje trazenog naziva sa nazivom iz odgovora API-ja
         p:= pos(ansilowerCase(edtFilter.Text),ansilowerCase(naziv));

         if p <> 0 then
         begin
           y[i,0]:= id;
           y[i,1]:= naziv;

           i:=i+1;
         end;

      end;
   end;

  end;

  gridArtikli.EndUpdate;

 end;



procedure TfrmDemo.btnPretragaObrTab2Click(Sender: TObject);
var
 JSonArray:TJSonArray;
 JSonValue :TJSonValue;
 iznos,naziv,st,vrstePlacanja,
 nadgrupaPlacanjaID,nadgrupaPlacanjaNaziv : string;
 ArrayElement: TJSonValue;
 FoundValue: TJSonValue;
 p,i,j:integer;
begin


  if (banPJTab2.text = '') then
  begin
     showmessage('Unesite ?ifu poslovne jedinice');
     banPJTab2.SetFocus;

     // brisanje podataka u grid-u
       gridObracunTab2.beginUpdate;
        FillChar(x, SizeOf(x), 0);
       gridObracunTab2.endUpdate;

     exit;
  end;

  gridObracunTab2.beginUpdate;


  restClient1.baseurl:= 'http://apidemo.luceed.hr/datasnap/rest/mpobracun/placanja/'+banPJTab2.text+'/'+datetostr(datumOdTab2.Date)+
                        '/'+ datetostr(datumDoTab2.Date);



  try
   restRequest1.Execute;
   except
     showmessage('Gre?ka prilikom konekcije na web servis');
      exit;
   end;



  // priprema JSON odgovora
  JSonValue:= restresponse1.JSONValue;
  JsonValue:=(JsonValue as TJSONObject).Get('result').JSONValue;


   st:=  rightstr(JsonValue.ToString,length(JsonValue.ToString)-1);
   st:=  leftStr (st,length(JsonValue.ToString)-2);

   JsonValue := TJSonObject.ParseJSONValue(st);
   JsonArray := JsonValue.GetValue<TJSONArray>('obracun_placanja');


   // inicijalizacija pomocnog niza x //

   i:=0;

   for ArrayElement in JsonArray do begin
      FoundValue := ArrayElement.FindValue('vrste_placanja_uid');
      if FoundValue <> nil then
       i:=i+1 ;
   end;

   FillChar(x, SizeOf(x), 0);
   SetLength(x, i, 5);



    // pretraga obracuna po tacki 3.3
   i:=0;

   for ArrayElement in JsonArray do begin
      FoundValue := ArrayElement.FindValue('vrste_placanja_uid');
      if FoundValue <> nil then begin

        vrstePlacanja:=  ArrayElement.GetValue<string>('vrste_placanja_uid');
        naziv := ArrayElement.GetValue<string>('naziv');
        iznos := ArrayElement.GetValue<string>('iznos');
        nadgrupaPlacanjaID:= ArrayElement.GetValue<string>('nadgrupa_placanja_uid');
        nadgrupaPlacanjaNaziv:= ArrayElement.GetValue<string>('nadgrupa_placanja_naziv');

        x[i,0]:= vrsteplacanja;
        x[i,1]:= naziv;
        x[i,2]:= iznos;
        x[i,3]:= nadgrupaPlacanjaID;
        x[i,4]:= nadgrupaPlacanjaNaziv;

          i:=i+1;
      end;
   end;

    gridObracunTab2.EndUpdate;

end;


procedure TfrmDemo.btnPretragaObrTab3Click(Sender: TObject);
var
 JSonArray:TJSonArray;
 JSonValue :TJSonValue;
 ArtikalID,naziv,st,kolicina,
 Iznos,usluga : string;
 ArrayElement: TJSonValue;
 FoundValue: TJSonValue;
 p,i,j:integer;
begin

  if (banPJTab3.text = '') then
  begin
     showmessage('Unesite ?ifu poslovne jedinice');
     banPJTab3.SetFocus;

     // brisanje podataka u grid-u
       gridObracunTab3.beginUpdate;
        FillChar(z, SizeOf(z), 0);
       gridObracunTab3.endUpdate;

     exit;
  end;

  gridObracunTab3.beginUpdate;


  restClient1.baseurl:= 'http://apidemo.luceed.hr/datasnap/rest/mpobracun/artikli/'+banPJTab3.text+'/'+datetostr(datumOdTab3.Date)+
                        '/'+ datetostr(datumDoTab3.Date);



  try
   restRequest1.Execute;
   except
     showmessage('Gre?ka prilikom konekcije na web servis');
      exit;
   end;



  // priprema JSON odgovora
  JSonValue:= restresponse1.JSONValue;
  JsonValue:=(JsonValue as TJSONObject).Get('result').JSONValue;


   st:=  rightstr(JsonValue.ToString,length(JsonValue.ToString)-1);
   st:=  leftStr (st,length(JsonValue.ToString)-2);

   JsonValue := TJSonObject.ParseJSONValue(st);
   JsonArray := JsonValue.GetValue<TJSONArray>('obracun_artikli');


   // inicijalizacija pomocnog niza z //

   i:=0;

   for ArrayElement in JsonArray do begin
      FoundValue := ArrayElement.FindValue('artikl_uid');
      if FoundValue <> nil then
       i:=i+1 ;
   end;

   FillChar(z, SizeOf(z), 0);
   SetLength(z, i, 5);



    // pretraga obracuna po tacki 3.4
   i:=0;

   for ArrayElement in JsonArray do begin
      FoundValue := ArrayElement.FindValue('artikl_uid');
      if FoundValue <> nil then begin

        ArtikalID:=  ArrayElement.GetValue<string>('artikl_uid');
        naziv := ArrayElement.GetValue<string>('naziv_artikla');
        kolicina := ArrayElement.GetValue<string>('kolicina');
        Iznos:= ArrayElement.GetValue<string>('iznos');
        usluga:= ArrayElement.GetValue<string>('usluga');

        z[i,0]:= ArtikalID;
        z[i,1]:= naziv;
        z[i,2]:= kolicina;
        z[i,3]:= Iznos;
        z[i,4]:= usluga;

          i:=i+1;
      end;
   end;

    gridObracunTab3.EndUpdate;

end;

procedure TfrmDemo.FormShow(Sender: TObject);
begin
     // inicijalizacija

   gridArtikli.Columns[0].Header:='ID';
   gridArtikli.Columns[1].Header:='Naziv';
   gridArtikli.ReadOnly:= true;

   gridObracunTab2.Columns[0].Header:='Vrsta pla?anja ID';
   gridObracunTab2.Columns[1].Header:='Naziv';
   gridObracunTab2.Columns[2].Header:='Iznos';
   gridObracunTab2.Columns[3].Header:='Nadgrupa pla?anja ID';
   gridObracunTab2.Columns[4].Header:='Nadgrupa pla?anja Naziv';

   gridObracunTab2.ReadOnly:= true;


   gridObracunTab3.Columns[0].Header:='Artikal UID';
   gridObracunTab3.Columns[1].Header:='Naziv';
   gridObracunTab3.Columns[2].Header:='Koli?ina';
   gridObracunTab3.Columns[3].Header:='Iznos';
   gridObracunTab3.Columns[4].Header:='Usluga';

   gridObracunTab3.ReadOnly:= true;
   datumDoTab2.Date:= now;
   datumDoTab3.Date:= now;


   btnPretragaArtikli.OnClick(self);
   btnPretragaObrTab2.OnClick(self);
   btnPretragaObrTab3.OnClick(self);


end;

procedure TfrmDemo.gridArtikliGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
     // punjenje GRID-a

 if Length(y)>0 then
   begin
      if ACol = 0 then
       if arow <=length(y)-1 then
          value  := y[arow,0];

      if ACol = 1 then
        if arow <=length(y)-1 then
           value  := y[arow,1];
   end;

end;

procedure TfrmDemo.gridObracunTab2GetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
      // punjenje GRID-a

  if Length(x)>0 then
     begin
       if ACol = 0 then
         if arow <=length(x)-1 then
            value  := x[arow,0];

       if ACol = 1 then
         if arow <=length(x)-1 then
            value  := x[arow,1];

       if ACol = 2 then
         if arow <=length(x)-1 then
            value  := x[arow,2];

       if ACol = 3 then
         if arow <=length(x)-1 then
            value  := x[arow,3];

       if ACol = 4 then
         if arow <=length(x)-1 then
            value  := x[arow,4];
    end;

end;


procedure TfrmDemo.GridObracunTab3GetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
begin
      // punjenje GRID-a

  if Length(z)>0 then
     begin
       if ACol = 0 then
         if arow <=length(z)-1 then
            value  := z[arow,0];

       if ACol = 1 then
         if arow <=length(z)-1 then
            value  := z[arow,1];

       if ACol = 2 then
         if arow <=length(z)-1 then
            value  := z[arow,2];

       if ACol = 3 then
         if arow <=length(z)-1 then
            value  := z[arow,3];

       if ACol = 4 then
         if arow <=length(z)-1 then
            value  := z[arow,4];
    end;

end;


end.
