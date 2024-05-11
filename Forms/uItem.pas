unit uItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListView.Types, FMX.ListView, Data.DB, MemDS,
  DBAccess, Uni, FMX.Edit, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope,
  Androidapi.JNI.Toast, FMX.ListView.Appearances, FMX.ListView.Adapters.Base;

type
  TFrmItem = class(TForm)
    lblTop: TLabel;
    btnTop: TButton;
    lblTitle: TLabel;
    btnBack: TButton;
    lblGoBack: TLabel;
    btnRefresh: TButton;
    lblRefresh: TLabel;
    pnlBottom: TPanel;
    lVitemList: TListView;
    tmrLoader: TTimer;
    tmrUpdate: TTimer;
    aInewList: TAniIndicator;
    btnVersion: TButton;
    lblCopy: TLabel;
    uDqry_ItemsLv: TUniQuery;
    bsDB_Items: TBindSourceDB;
    bl_Items: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    pnlAbsItem: TPanel;
    edtBrandItem: TEdit;
    edtDurItem: TEdit;
    edtQtdItem: TEdit;
    lblInfAbsItem: TLabel;
    btnAddAbsItem: TButton;
    edtDescItem: TEdit;
    uDqry_ItemsLvid: TIntegerField;
    uDqry_ItemsLvdescricao: TMemoField;
    uDqry_ItemsLvmarca: TStringField;
    uDqry_ItemsLvquantidade: TStringField;
    uDqry_ItemsLvdur_dias: TSmallintField;
    uDqry_ItemsLvfk_lista: TIntegerField;
    pnlListData: TPanel;
    lblListCode: TLabel;
    edtListCode: TEdit;
    btnSearchList: TButton;
    edtCat: TEdit;
    edtMonth: TEdit;
    edtYear: TEdit;
    btnEdit: TButton;
    lblSearch: TLabel;
    lblEdit: TLabel;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrLoaderTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnSearchListClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tmrUpdateTimer(Sender: TObject);
    procedure uDqry_ItemsLvBeforeOpen(DataSet: TDataSet);
    procedure lVitemListItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure edtDescItemEnter(Sender: TObject);
    procedure edtBrandItemEnter(Sender: TObject);
    procedure edtDurItemEnter(Sender: TObject);
    procedure edtDescItemExit(Sender: TObject);
    procedure edtBrandItemExit(Sender: TObject);
    procedure edtQtdItemExit(Sender: TObject);
    procedure edtDurItemExit(Sender: TObject);
    procedure btnAddAbsItemClick(Sender: TObject);
    procedure edtQtdItemEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmItem: TFrmItem;
  segundos: integer;

implementation

{$R *.fmx}

uses uDmData, uMain, uItemInfo;

procedure TFrmItem.btnAddAbsItemClick(Sender: TObject);
var
 uDQryUp: TUniQuery;
 uDQryAbsItem: TUniQuery;
begin
 //Adiciona item restante
 if (edtDescItem.Text <> 'Descri��o') and (edtBrandItem.Text <> 'Marca') and
  (edtQtdItem.Text <> 'Quantidade') and (edtDurItem.Text <> 'Dura��o (dias)') then
  begin
   try
    uDQryAbsItem := TUniQuery.Create(nil);
    uDQryAbsItem.Connection := DmData.uDconn_pg;

    uDQryAbsItem.SQL.Text := ' INSERT INTO public.item_lista'+
                             ' (descricao,marca,quantidade,dur_dias,fk_lista)'+
                             ' VALUES('+
                             QuotedStr(edtDescItem.Text)+','+
                             QuotedStr(FrmItemInfo.isBrandOrNo(edtBrandItem.Text))+','+
                             QuotedStr(edtQtdItem.Text)+','+
                             edtDurItem.Text+','+
                             edtListCode.Text+')';
    uDQryAbsItem.ExecSQL;

   finally
    Androidapi.JNI.Toast.Toast('Item salvo/Lista editada.');
    uDQryAbsItem.Free;
   end;

   try
      // Atualiza a lista buscada
      uDQryUp := TUniQuery.Create(nil);
      uDQryUp.Connection := DmData.uDconn_pg;

      uDQryUp.SQL.Text := ' UPDATE public.lista_comp SET'+
                          ' categoria ='+QuotedStr(edtCat.Text)+','+
                          ' mes ='+QuotedStr(edtMonth.Text)+','+
                          ' ano ='+edtYear.Text+
                          ' WHERE id ='+edtListCode.Text;
      uDQryUp.ExecSQL;

   finally
      uDQryUp.Free;
   end;
   //Restaura padrao
   edtDescItem.Text := 'Descri��o';
   edtBrandItem.Text := 'Marca';
   edtQtdItem.Text := 'Quantidade';
   edtDurItem.Text := 'Dura��o';

   // Atualiza tela
   pnlAbsItem.Visible := False;
   pnlListData.Visible := True;
   btnRefreshClick(Sender);
  end
  else
   ShowMessage('Preencha todos os campos!');
end;

procedure TFrmItem.btnBackClick(Sender: TObject);
begin
  //Volta para tela principal
  btnEdit.Enabled := False;
  Close;
end;

procedure TFrmItem.btnEditClick(Sender: TObject);
var
  uDQryUp: TUniQuery;
begin
 if (edtCat.Text = 'Mensal') or (edtCat.Text = 'Quinzenal') or (edtCat.Text = 'Semanal') then
 begin
  if (edtMonth.Text <> '') and (edtYear.Text <> '') then
  MessageDlg('Acrescentar itens?', System.UITypes.TMsgDlgType.mtInformation,
  [
   System.UITypes.TMsgDlgBtn.mbYes,
   System.UITypes.TMsgDlgBtn.mbNo,
   System.UITypes.TMsgDlgBtn.mbCancel
  ], 0,
   procedure(const AResult: System.UITypes.TModalResult)
   begin
    case Aresult of
    mrYES:
    begin
     // Troca visibilidade
     pnlListData.Visible := False;
     pnlAbsItem.Visible := True;
    end;
    mrNo:
     try
      // Atualiza a lista buscada
      uDQryUp := TUniQuery.Create(nil);
      uDQryUp.Connection := DmData.uDconn_pg;

      uDQryUp.SQL.Text := ' UPDATE public.lista_comp SET'+
                          ' categoria ='+QuotedStr(edtCat.Text)+','+
                          ' mes ='+QuotedStr(edtMonth.Text)+','+
                          ' ano ='+edtYear.Text+
                          ' WHERE id ='+edtListCode.Text;
      uDQryUp.ExecSQL;

     finally
      Androidapi.JNI.Toast.Toast('Lista editada.');
      uDQryUp.Free;
     end;
     // Sai
     mrCancel:
      Exit;
    end;
   end);
 end
 else
  // Valida campos
  ShowMessage('Preencha todos os campos corretamente!'+sLineBreak+
              'OBS: As categorias podem ser apenas:'+sLineBreak+
              '"Mensal", "Quinzenal" ou "Semanal."');
 end;

procedure TFrmItem.btnRefreshClick(Sender: TObject);
begin
 // Atualiza lista de itens
 tmrLoader.Enabled := True;

 if (uDqry_ItemsLv.Active) then
 begin
  uDqry_ItemsLv.Close;
  uDqry_ItemsLv.Open;
 end;
end;

procedure TFrmItem.btnSearchListClick(Sender: TObject);
var
  uDQrySel: TUniQuery;
begin
 if (edtListCode.Text <> '') then
 begin
  // Busca a lista informada
  uDQrySel := TUniQuery.Create(nil);
  uDQrySel.Connection := DmData.uDconn_pg;

  try
  uDQrySel.SQL.Text := ' SELECT * FROM public.lista_comp'+
                       ' WHERE id ='+edtListCode.Text;
  uDQrySel.Open;

  if not uDQrySel.IsEmpty then
  begin
   edtCat.ReadOnly := False;
   edtMonth.ReadOnly := False;
   edtYear.ReadOnly := False;
   // Popula campos
   edtCat.Text := uDQrySel.FieldByName('categoria').AsString;
   edtMonth.Text := uDQrySel.FieldByName('mes').AsString;
   edtYear.Text := uDQrySel.FieldByName('ano').AsString;

   // Exibe itens
   uDqry_ItemsLv.Active := True;
   btnEdit.Enabled := True;
  end
  else
  begin
   Androidapi.JNI.Toast.Toast('Lista inexistente.');
  end;

  finally
   uDQrySel.Free;
  end;
 end
 else
  ShowMessage('C�digo n�o informado!');
end;

procedure TFrmItem.edtBrandItemEnter(Sender: TObject);
begin
 if (edtBrandItem.Text = 'Marca') then
  edtBrandItem.Text := '';
end;

procedure TFrmItem.edtBrandItemExit(Sender: TObject);
begin
  if (edtBrandItem.Text = '') then
   edtBrandItem.Text := 'Marca';
end;


procedure TFrmItem.edtDescItemEnter(Sender: TObject);
begin
 if (edtDescItem.Text = 'Descri��o') then
  edtDescItem.Text := '';
end;

procedure TFrmItem.edtDescItemExit(Sender: TObject);
begin
  if (edtDescItem.Text = '') then
   edtDescItem.Text := 'Descri��o';
end;

procedure TFrmItem.edtDurItemEnter(Sender: TObject);
begin
 if (edtDurItem.Text = 'Dura��o (dias)') then
  edtDurItem.Text := '';
end;

procedure TFrmItem.edtDurItemExit(Sender: TObject);
begin
  if (edtDurItem.Text = '') then
   edtDurItem.Text := 'Dura��o (dias)';
end;

procedure TFrmItem.edtQtdItemEnter(Sender: TObject);
begin
 if (edtQtdItem.Text = 'Quantidade') then
  edtQtdItem.Text := '';
end;

procedure TFrmItem.edtQtdItemExit(Sender: TObject);
begin
  if (edtQtdItem.Text = '') then
   edtQtdItem.Text := 'Quantidade';
end;

procedure TFrmItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Deixa texto padrao
  edtCat.Text := 'Categoria';
  edtMonth.Text := 'M�s';
  edtYear.Text := 'Ano';

  // Desativa e atualiza listas
  tmrUpdate.Enabled := False;
  FrmMain.uDqry_Lists.Refresh;

  // Alerta o vencimento proximo
  DmData.altMaturity;
end;

procedure TFrmItem.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Fecha conexao da ListView
  if uDqry_ItemsLv.Active then
   uDqry_ItemsLv.Close;
end;

procedure TFrmItem.FormCreate(Sender: TObject);
begin
  // Controla
  segundos := 0;
end;

procedure TFrmItem.FormShow(Sender: TObject);
begin
  // Deixa travado
  edtCat.ReadOnly := True;
  edtMonth.ReadOnly := True;
  edtYear.ReadOnly := True;

  // Ativa timer
  tmrUpdate.Enabled := True;
end;

procedure TFrmItem.lVitemListItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  ItemControl := 'U';

  // Invoca tela com as informacoes do item para edicao
  FrmItemInfo := TFrmItemInfo.Create(self);
  FrmItemInfo.Show;
end;

procedure TFrmItem.tmrLoaderTimer(Sender: TObject);
begin
 // Trata exibicao do Loader ao atulizar lista
 aInewList.Enabled := True;
 aInewList.Visible := True;
 Application.ProcessMessages;

 segundos := segundos+1;

  if (segundos = 2) then
  begin
    aInewList.Visible := False;
    aInewList.Enabled := False;
    Application.ProcessMessages;

    segundos := 0;
    tmrLoader.Enabled := False;
  end;
end;

procedure TFrmItem.tmrUpdateTimer(Sender: TObject);
begin
 // Atualiza a cada 5 segundos
 if (uDqry_ItemsLv.Active) then
 begin
  uDqry_ItemsLv.Close;
  uDqry_ItemsLv.Open;
 end;
end;

procedure TFrmItem.uDqry_ItemsLvBeforeOpen(DataSet: TDataSet);
begin
  uDqry_ItemsLv.SQL[2] := ' WHERE fk_lista ='+edtListCode.Text;
end;

end.
