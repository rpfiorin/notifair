unit uDmData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, FMX.Platform,
  Uni, UniProvider, PostgreSQLUniProvider, System.Notification;

type
  TDmData = class(TDataModule)
    uDconn_pg: TUniConnection;
    uDpgProv: TPostgreSQLUniProvider;
    ncPush: TNotificationCenter;

    procedure DataModuleCreate(Sender: TObject);
    procedure altMaturity;
    procedure ncPushReceiveLocalNotification(Sender: TObject;
      ANotification: TNotification);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DmData: TDmData;
  ItemControl: String;
  Nitems: Integer;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uItem;

{$R *.dfm}

procedure TDmData.altMaturity;
var
 uDqrMaturity: TUniQuery;
 Ntf: TNotification;
begin
 try
 // Instancia conexao ao BD
 uDqrMaturity := TUniQuery.Create(nil);
 uDqrMaturity.Connection := uDconn_pg;

 // Busca registros das listas
 uDqrMaturity.SQL.Text := ' SELECT id, dt_fim'+
                          ' FROM'+
                          ' public.lista_comp';
 uDqrMaturity.Open;
 uDqrMaturity.First;

  // Varre verificando se esta proximo de vencer
  while not uDqrMaturity.Eof do
  begin
   if ((uDqrMaturity.Fields[1].AsDateTime - Now) <= 3) then
   begin
    // Cria e exibe a notificacao push
    Ntf := ncPush.CreateNotification;
    Ntf.AlertBody := 'Itens da lista de código '
                     +uDqrMaturity.Fields[0].AsString+
                     ' podem estar acabando.'+sLineBreak+
                     ' Verifique e lembre-se deles na próxima ida ao mercado!';

    if (ncPush.Tag = 0) then
    begin
     Ntf.Number := 1;
     Ntf.EnableSound := True;

     ncPush.PresentNotification(Ntf);
     ncPush.Tag := 1;
    end;
   end;
   uDqrMaturity.Next;
  end;

 // Destroi
 finally
 uDqrMaturity.Free;
 end;
end;

procedure TDmData.DataModuleCreate(Sender: TObject);
{
var
  uDqryUtis: TUniQuery;
  CurDate: String;
}
begin
{
  // Pega data corrente
  CurDate := FormatDateTime('YYYY/MM/DD', Date);

  // Cria query
  uDqryUtis := TUniQuery.Create(nil);
  uDqryUtis.Connection := uDconn_pg;

  // Exclui listas vencidas
  uDqryUtis.SQL.Text := ' DELETE FROM public.lista_comp'+
                        ' WHERE dt_fim ='+QuotedStr(CurDate);
  uDqryUtis.ExecSQL;
}
end;

procedure TDmData.ncPushReceiveLocalNotification(Sender: TObject;
  ANotification: TNotification);
begin
  // Chama tela de detalhes da lista
  FrmItem := TFrmItem.Create(self);
  FrmItem.Show;
end;

end.
