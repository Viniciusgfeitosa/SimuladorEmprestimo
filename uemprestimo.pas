unit uEmprestimo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCalcular: TButton;
    btnLimpar: TButton;
    edtParcelas: TEdit;
    edtValor: TEdit;
    lblParcelas: TLabel;
    lblValor: TLabel;
    lblParcela: TLabel;
    lblTotalPago: TLabel;
    lblTotalJuros: TLabel;
    procedure btnCalcularClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
  private
    function ParseFloatBR(const S: string): Double;
    function ParseIntSafe(const S: string): Integer;
    function FormatBRL(const V: Double): string;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  TAXA_FIXA = 0.02; // 2% ao mês

// Funções auxiliares

function TForm1.ParseFloatBR(const S: string): Double;
var
  fs: TFormatSettings;
begin
  fs := DefaultFormatSettings;

  fs.DecimalSeparator := ',';
  if TryStrToFloat(Trim(S), Result, fs) then Exit;

  fs.DecimalSeparator := '.';
  if TryStrToFloat(Trim(S), Result, fs) then Exit;

  raise Exception.Create('Valor inválido.');
end;

function TForm1.ParseIntSafe(const S: string): Integer;
begin
  if not TryStrToInt(Trim(S), Result) then
    raise Exception.Create('Número de parcelas inválido.');
end;

function TForm1.FormatBRL(const V: Double): string;
var
  fs: TFormatSettings;
begin
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := ',';
  fs.ThousandSeparator := '.';
  Result := 'R$ ' + FormatFloat('#,##0.00', V, fs);
end;

// Eventos

procedure TForm1.btnCalcularClick(Sender: TObject);
var
  valor: Double;
  parcelas: Integer;
  parcela, totalPago, totalJuros: Double;
  i: Double;
begin
  try
    if Trim(edtValor.Text) = '' then
      raise Exception.Create('Informe o valor.');

    if Trim(edtParcelas.Text) = '' then
      raise Exception.Create('Informe o número de parcelas.');

    valor := ParseFloatBR(edtValor.Text);
    parcelas := ParseIntSafe(edtParcelas.Text);

    if valor <= 0 then
      raise Exception.Create('Valor deve ser maior que zero.');

    if parcelas <= 0 then
      raise Exception.Create('Parcelas deve ser maior que zero.');

    i := TAXA_FIXA;

    parcela := valor * (i * Power(1 + i, parcelas)) /
               (Power(1 + i, parcelas) - 1);

    totalPago := parcela * parcelas;
    totalJuros := totalPago - valor;

    lblParcela.Caption := 'Parcela: ' + FormatBRL(parcela);
    lblTotalPago.Caption := 'Total pago: ' + FormatBRL(totalPago);
    lblTotalJuros.Caption := 'Total de juros: ' + FormatBRL(totalJuros);

  except
    on E: Exception do
      MessageDlg('Erro', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TForm1.btnLimparClick(Sender: TObject);
begin
  edtValor.Clear;
  edtParcelas.Clear;

  lblParcela.Caption := 'Parcela: -';
  lblTotalPago.Caption := 'Total pago: -';
  lblTotalJuros.Caption := 'Total de juros: -';

  edtValor.SetFocus;
end;

end.

