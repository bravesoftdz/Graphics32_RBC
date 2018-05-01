unit GR32_Widgets_Circle;

interface

uses
    GR32_Widgets_Base
  , GR32_Rubicube_Utils         //  Rubicube extensions
  , GR32                        //  TBitmap32
  , GR32_ColorGradients         //  TColor32, ColorTo
  , GR32_Polygons               //  Poligon hesaplama form�lleri
  , System.Classes              //  TComponent
  , System.SysUtils             //  FreeAndNil
  , System.Math                 //  Min
  , Vcl.Graphics                //  TColor
  , Vcl.Controls                //  TCustomControl
  ;

type
  TGR32WidgetCircleFillStyle = ( wfsEventOdd, wfsAlternatif, wfsWinding, wfsNonZero );//TPolyFillMode; // (pfAlternate, pfWinding, pfEvenOdd = 0, pfNonZero);
  TGR32WidgetCircleFillStyle_Helper = record helper for TGR32WidgetCircleFillStyle
    public
      function toPolyFillMode: TPolyFillMode;
  end;
  TGR32WidgetCircleStyle = (wgtDaire, wgtPasta);
  TGR32WidgetCircle = class(TGR32CustomWidget)
    type
      TGR32WidgetCircleSettings = class(TPersistent)
        private
          FOwner        : TGR32WidgetCircle;
          FAntiAliased  : Boolean;
          FBackground   : TColor;
          FBorderColor  : TColor;
          FBorderWidth  : Integer;
          FDisplayFormat: String;
          FFont         : TFont;
          FFrameColor   : TColor;
          FFrameWidth   : Integer;
          FHeader       : TFont;
          FHeaderPos    : TFontPos;
          FHeaderHeight : Integer;
          FStyle        : TGR32WidgetCircleStyle;
          FStyleFill    : TGR32WidgetCircleFillStyle;
          FStyleLine    : TPenStyle;
          FBaseColor    : TColor;
          FValueColor   : TColor;
          FInnerColor   : TColor;
          FOuterColor   : TColor;
          FIntraColor   : TColor;
          FPadding      : TPadding;
          procedure SetAntiAliased(const Value: Boolean);
          procedure SetBackground(const Value: TColor);
          procedure SetBorderColor(const Value: TColor);
          procedure SetBorderWidth(const Value: Integer);
          procedure SetDisplayFormat(const Value: String);
          procedure SetFont(const Value: TFont);
          procedure SetFrameColor(const Value: TColor);
          procedure SetFrameWidth(const Value: Integer);
          procedure SetHeader(const Value: TFont);
          procedure SetHeaderPos(const Value: TFontPos);
          procedure SetHeaderHeight(const Value: Integer);
          procedure SetStyle(const Value: TGR32WidgetCircleStyle);
          procedure SetStyleFill(const Value: TGR32WidgetCircleFillStyle);
          procedure SetStyleLine(const Value: TPenStyle);
          procedure SetBaseColor(const Value: TColor);
          procedure SetValueColor(const Value: TColor);
          procedure SetInnerColor(const Value: TColor);
          procedure SetOuterColor(const Value: TColor);
          procedure SetIntraColor(const Value: TColor);
          procedure SetPadding(const Value: TPadding);
          procedure InlineChangeNotifier(Sender: TObject);
        protected
        public
          procedure Assign(Source: TPersistent); reintroduce;
          procedure AfterConstruction; override;
          procedure BeforeDestruction; override;
          procedure ResetSettings;
        published
          property AntiAliased  : Boolean                     read FAntiAliased   write SetAntiAliased;
          property Background   : TColor                      read FBackground    write SetBackground;
          property BorderColor  : TColor                      read FBorderColor   write SetBorderColor;
          property BorderWidth  : Integer                     read FBorderWidth   write SetBorderWidth;
          property DisplayFormat: String                      read FDisplayFormat write SetDisplayFormat;
          property Font         : TFont                       read FFont          write SetFont;
          property FrameColor   : TColor                      read FFrameColor    write SetFrameColor;
          property FrameWidth   : Integer                     read FFrameWidth    write SetFrameWidth;
          property Header       : TFont                       read FHeader        write SetHeader;
          property HeaderPos    : TFontPos                    read FHeaderPos     write SetHeaderPos;
          property HeaderHeight : Integer                     read FHeaderHeight  write SetHeaderHeight;
          property Style        : TGR32WidgetCircleStyle      read FStyle         write SetStyle;
          property StyleFill    : TGR32WidgetCircleFillStyle  read FStyleFill     write SetStyleFill;
          property StyleLine    : TPenStyle                   read FStyleLine     write SetStyleLine;
          property BaseColor    : TColor                      read FBaseColor     write SetBaseColor;   //  Dairenin de�er d���nda kalan k�sm�n�n rengi
          property ValueColor   : TColor                      read FValueColor    write SetValueColor;  //  Dairenin de�er i�eren k�sm�n�n rengi
          property InnerColor   : TColor                      read FInnerColor    write SetInnerColor;  //  Dairenin i� �er�eve rengi
          property OuterColor   : TColor                      read FOuterColor    write SetOuterColor;  //  Dairenin d�� �er�eve rengi
          property IntraColor   : TColor                      read FIntraColor    write SetIntraColor;  //  Dairenin merkezinin rengi
          property Padding      : TPadding                    read FPadding       write SetPadding;
      end;
    private
      FAyarlar    : TGR32WidgetCircleSettings;
      FHeaderText : String;
      FYuzde      : Integer;
      FOnChange   : TNotifyEvent;
      procedure SetAyarlar(const Value: TGR32WidgetCircleSettings);
      procedure SetHeaderText(const Value: String);
      procedure SetYuzde(const Value: Integer);
    protected
      procedure Changed; dynamic;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy(); override;
      procedure PaintControl; override;
    published
      property Ayarlar    : TGR32WidgetCircleSettings read FAyarlar     write SetAyarlar;
      property HeaderText : String                    read FHeaderText  write SetHeaderText;
      property Yuzde      : Integer                   read FYuzde       write SetYuzde;
      property OnChange   : TNotifyEvent              read FOnChange    write FOnChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Graphics32RBC', [TGR32WidgetCircle]);
end;

{ TGR32WidgetCircleFillStyle_Helper }

function TGR32WidgetCircleFillStyle_Helper.toPolyFillMode: TPolyFillMode;
begin
  case Self of
    wfsEventOdd   : Result := pfEvenOdd;
    wfsAlternatif : Result := pfAlternate;
    wfsWinding    : Result := pfWinding;
    wfsNonZero    : Result := pfNonZero;
  end;
end;

{ TGR32WidgetCircle.TGR32WidgetCircleSettings }

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.AfterConstruction;
begin
  inherited;
  FFont             := TFont.Create;
  FHeader           := TFont.Create;
  FPadding          := TPadding.Create(FOwner);
  FFont.OnChange    := InlineChangeNotifier;
  FHeader.OnChange  := InlineChangeNotifier;
  FPadding.OnChange := InlineChangeNotifier;
  ResetSettings;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.Assign(Source: TPersistent);
var
  aSors: TGR32WidgetCircle.TGR32WidgetCircleSettings;
begin
  if (Source is TGR32WidgetCircle.TGR32WidgetCircleSettings) then begin
      aSors := TGR32WidgetCircle.TGR32WidgetCircleSettings(Source);
      //FOwner      := BU KULLANILMAYACAK..
      FBackground   := aSors.Background   ;
      FBorderColor  := aSors.BorderColor  ;
      FBorderWidth  := aSors.BorderWidth  ;
      FDisplayFormat:= aSors.DisplayFormat;
      FFont         := aSors.Font         ;
      FFrameColor   := aSors.FrameColor   ;
      FFrameWidth   := aSors.FrameWidth   ;
      FHeader       := aSors.Header       ;
      FHeaderPos    := aSors.HeaderPos    ;
      FHeaderHeight := aSors.HeaderHeight ;
      FStyle        := aSors.Style        ;
      FStyleFill    := aSors.StyleFill    ;
      FBaseColor    := aSors.BaseColor    ;
      FValueColor   := aSors.ValueColor   ;
      FInnerColor   := aSors.InnerColor   ;
      FOuterColor   := aSors.OuterColor   ;
      FIntraColor   := aSors.IntraColor   ;
      FPadding      := aSors.Padding      ;
  end else inherited;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.BeforeDestruction;
begin
  FreeAndNil(FPadding);
  FreeAndNil(FFont);
  FreeAndNil(FHeader);
  inherited;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.InlineChangeNotifier(Sender: TObject);
begin
  // Persistent s�n�f�n alt type'lerinde bir de�i�iklik oldu�unda ana s�n�f�n grafi�inin yeniden �izilmesini tetikler...
  if Assigned(FOwner) then FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.ResetSettings;
begin
  FAntiAliased  := False;
  FBackground   := clWindow;
  FBorderColor  := clWindowFrame;
  FBorderWidth  := 1;
  FDisplayFormat:= '%%%D';
  with FFont do begin
        Color   := clWindowText;
        Name    := 'Calibri';
        Size    := 24;
        Style   := [];
  end;
  FFrameColor   := clWindowFrame;
  FFrameWidth   := 1;
  with FHeader do begin
        Color   := clHotLight;
        Name    := 'Calibri';
        Size    := 16;
        Style   := [];
  end;
  FHeaderPos    := fpCenterCenter;
  FHeaderHeight := 50;
  FStyle        := wgtDaire;
  FStyleFill    := wfsEventOdd;
  FValueColor   := $005233DC;
  FBaseColor    := $00D9D3E7; // $00AB9DEE;
  FInnerColor   := clBtnFace;
  FOuterColor   := clBtnFace;
  FIntraColor   := clWindow;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetAntiAliased(const Value: Boolean);
begin
  FAntiAliased := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetBackground(const Value: TColor);
begin
  FBackground := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetBaseColor(const Value: TColor);
begin
  FBaseColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetBorderWidth(const Value: Integer);
begin
  if (Trunc(Value) > 0) then FBorderWidth := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetDisplayFormat(const Value: String);
begin
  FDisplayFormat := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetFrameColor(const Value: TColor);
begin
  FFrameColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetFrameWidth(const Value: Integer);
begin
  if (Trunc(Value) > 0) then FFrameWidth := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetHeader(const Value: TFont);
begin
  FHeader.Assign(Value);
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetHeaderHeight(const Value: Integer);
begin
  FHeaderHeight := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetHeaderPos(const Value: TFontPos);
begin
  FHeaderPos := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetInnerColor(const Value: TColor);
begin
  FInnerColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetIntraColor(const Value: TColor);
begin
  FIntraColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetOuterColor(const Value: TColor);
begin
  FOuterColor := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetPadding(const Value: TPadding);
begin
  FPadding.Assign(Value);
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetStyle(const Value: TGR32WidgetCircleStyle);
begin
  FStyle := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetStyleFill(const Value: TGR32WidgetCircleFillStyle);
begin
  FStyleFill := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetStyleLine(const Value: TPenStyle);
begin
  FStyleLine := Value;
  FOwner.Invalidate;
end;

procedure TGR32WidgetCircle.TGR32WidgetCircleSettings.SetValueColor(const Value: TColor);
begin
  FValueColor := Value;
  FOwner.Invalidate;
end;

{ TGR32WidgetCircle }

procedure TGR32WidgetCircle.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TGR32WidgetCircle.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  FAyarlar := TGR32WidgetCircleSettings.Create;
  FAyarlar.FOwner := SELF; { !!! }
  FAyarlar.FPadding.SetBounds(10, 10, 10, 10);
  Margins.SetBounds(10, 10, 10, 10);
  FHeaderText := 'Header';
end;

destructor TGR32WidgetCircle.Destroy;
begin
  FreeAndNil(FAyarlar);
  inherited Destroy;
end;

procedure TGR32WidgetCircle.SetAyarlar(const Value: TGR32WidgetCircleSettings);
begin
  FAyarlar.Assign(Value);
  Invalidate;
end;

procedure TGR32WidgetCircle.SetHeaderText(const Value: String);
begin
  FHeaderText := Value;
  Invalidate;
end;

procedure TGR32WidgetCircle.SetYuzde(const Value: Integer);
begin
  if (Value < 0) or (Value > 100) then exit;
  if (FYuzde <> Value) then FYuzde := Value;
  Invalidate;
  Changed;
end;

procedure TGR32WidgetCircle.PaintControl;
var
  T, L, W, H{, W2, H2}  : Integer;  // Genel �er�eve bilgisi
  HT,HL,HW,HH,HW2,HH2 : Integer;  // Header k�sm�n�n �er�eve bilgisi
  FT, FL, FW, FH, FW2, FH2: Integer; // Frame k�sm�n�n �er�eve bilgisi
  _BW, _FW : Integer;

  MinWH         : Integer;            //  Merkez de�i�kenin en ve boy aras�ndaki en ufa�� kastediliyor.

  MR            : TFloatPoint;
  HM            : TFloatPoint;
  FM            : TFloatPoint;
  R             : TRect;

  Ressam        : TPolygonRenderer32VPR; // TPolygonRenderer32; //  Tuval
begin
  Ressam          := TPolygonRenderer32VPR.Create;
  Ressam.Filler   := nil; // hen�z bir gradient kullanmad�k.
  Ressam.FillMode := FAyarlar.StyleFill.toPolyFillMode; // pfWinding; // bu ayar, iki �izgi �st �ste kesi�ti�inde �izgilerin kesi�ti�i k�s�mlar�n birbirini yok etmesini engeller...
  Ressam.Bitmap   := Self.FBuffer;
  Ressam.Bitmap.Clear( Color32(FAyarlar.Background) ); // Tuvalin zemin rengi ve tam temizlik

  //  Genel �er�eve bilgileri hesaplan�yor.
  T  := 0;
  L  := 0;
  W  := ClientWidth ;
  H  := ClientHeight;
  //W2 := W div 2;
  //H2 := H div 2;
  MR.X := Merkez.X;// (W * 0.5);
  MR.Y := Merkez.Y;// (H * 0.5);

  if (FAyarlar.BorderWidth >= 1)
  and (FAyarlar.BorderColor <> FAyarlar.FBackground)
  then Ressam.SekilBas( Color32(FAyarlar.BorderColor), Ressam.DikDortgenCizgi(MR, W, H, FAyarlar.BorderWidth, FAyarlar.StyleLine));

  //  Header k�sm� hesaplan�yor

  _BW := FAyarlar.BorderWidth;
  _FW := FAyarlar.FrameWidth;

  HT   := T + FAyarlar.FPadding.Top + _BW;
  HL   := L + FAyarlar.FPadding.Left + _BW;
  HW   := W - (FAyarlar.FPadding.Left + FAyarlar.FPadding.Right + (_BW * 2));
  HW2  := HW div 2;
  HH   := FAyarlar.HeaderHeight + _BW;
  HH2  := HH div 2;
  HM.X := (HW * 0.5) + HL;
  HM.Y := (HH * 0.5) + HT;
  R := TRect.Create(HL, HT, HW, HH);

  //  Header k�sm� �iziliyor...
  //Ressam.YaziBas( HL + HW2, HT + HH2, FHeaderText, FAyarlar.Header.Color, FAyarlar.Header.Size, FAyarlar.Header.Name, FAyarlar.HeaderPos, FAyarlar.Header.Style);
  Ressam.YaziBas( R, FHeaderText, FAyarlar.Header.Color, FAyarlar.Header.Size, FAyarlar.Header.Name, FAyarlar.HeaderPos, FAyarlar.Header.Style);

  //  Frame k�sm� hesaplan�yor
  FT   := HT + HH;
  FL   := HL;
  FW   := HW;
  FW2  := HW2;
  FH   := H - (FT + FAyarlar.FPadding.Bottom + _BW);
  FH2  := FH div 2;

  FM.X := (FW * 0.5) + FL;
  FM.Y := (FH * 0.5) + FT;

  //  Frame k�sm� �iziliyor...

  if (FAyarlar.FrameWidth >= 1)
  and (FAyarlar.FrameColor <> FAyarlar.FBackground)
  then Ressam.SekilBas( Color32(FAyarlar.FrameColor), Ressam.DikDortgenCizgi(FM, FW, FH, FAyarlar.FrameWidth, FAyarlar.StyleLine));

  MinWH := (Min(FW, FH) div 2) - _FW;

  if (FAyarlar.Style = wgtDaire) then begin
      Ressam.SekilBas( Color32(FAyarlar.OuterColor) , Ressam.Daire(FM, MinWH) );                              // D�� Kenar Daire
      Ressam.SekilBas( Color32(FAyarlar.BaseColor)  , Ressam.Daire(FM, MinWH * 0.96  ) );                     // Yay zemin

      Ressam.SekilBas( Color32(FAyarlar.ValueColor) , Ressam.Pasta(FM, MinWH * 0.96  , FYuzde, Pi_0) );       // Yay

      Ressam.SekilBas( Color32(FAyarlar.InnerColor) , Ressam.Daire(FM, MinWH * 0.64  ) );                     // �� Kenar Daire
      Ressam.SekilBas( Color32(FAyarlar.IntraColor) , Ressam.Daire(FM, MinWH * 0.60  ) );                     // �� Zemin Daire
  end else
  if (FAyarlar.Style = wgtPasta) then begin
      Ressam.SekilBas( Color32(FAyarlar.OuterColor) , Ressam.Daire(FM, MinWH) );                              // D�� Kenar Daire
      Ressam.SekilBas( Color32(FAyarlar.BaseColor)  , Ressam.Daire(FM, MinWH * 0.96  ) );                     // Yay zemin
      Ressam.SekilBas( Color32(FAyarlar.InnerColor) , Ressam.Daire(FM, MinWH * 0.64  ) );                     // �� Kenar Daire
      Ressam.SekilBas( Color32(FAyarlar.IntraColor) , Ressam.Daire(FM, MinWH * 0.60  ) );                     // �� Zemin Daire

      Ressam.SekilBas( Color32(FAyarlar.ValueColor) , Ressam.Pasta(FM, MinWH * 0.96  , FYuzde, Pi_0) );       // Yay
  end;

  Ressam.YaziBas( FL + FW2
                , FT + FH2
                , Format(FAyarlar.DisplayFormat, [FYuzde])
                , FAyarlar.Font.Color
                , FAyarlar.Font.Size
                , FAyarlar.Font.Name
                , fpCenterCenter
                , FAyarlar.Font.Style
                , FAyarlar.AntiAliased
                );
  Ressam.Free;
end;

end.