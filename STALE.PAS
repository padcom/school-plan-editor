Unit Stale;

interface

const
  { ilo˜† dni w tygodniu }
  IloscDni = 5;
  NazwyDniTygodnia: array[1..IloscDni] of String =
    ('Poniedziaˆek','Wtorek','—roda','Czwartek','Pi¥tek');

  { komendy programu }
  cmNauczycielAdd   = 100;
  cmNauczycielDel   = 101;
  cmNauczycielEdit  = 102;
  cmNauczycielDelAll= 103;
  cmPrzedmiotAdd    = 110;
  cmPrzedmiotDel    = 111;
  cmPrzedmiotEdit   = 112;
  cmPrzedmiotDelAll = 113;
  cmKlasaAdd        = 120;
  cmKlasaDel        = 121;
  cmKlasaEdit       = 122;
  cmKlasaDelAll     = 123;
  cmSalaAdd         = 130;
  cmSalaDel         = 131;
  cmSalaEdit        = 132;
  cmSalaDelAll      = 133;
  cmDzwonekAdd      = 140;
  cmDzwonekDel      = 141;
  cmDzwonekEdit     = 142;
  cmDzwonekDelAll   = 143;
  cmLekcjaAdd       = 150;
  cmLekcjaDel       = 151;
  cmLekcjaEdit      = 152;
  cmLekcjaDelAll    = 153;
  cmArchiwizacja    = 160;
  cmOdzysk          = 161;
  cmAboutBox        = 170;
  cmPlanNauczyciela = 180;
  cmPlanKlasy       = 181;
  cmClickActiveText = 250;
  cmChooseFromList  = 251;
  cmUpdateLists            = 1000;
  cmDataBaseChanged        = 1001;
  cmListItemChanged        = 1002;
  cmUpdateDzwonekListView  = 1003;
  cmUpdateLekcjaListView   = 1004;
  cmUpdateLekcjaDetailView = 1005;
  cmFindEditorWindow       = 1006;

  { konteksty pomocy }
  hcNauczycielAdd   = $1100;
  hcNauczycielDel   = $1101;
  hcNauczycielEdit  = $1102;
  hcNauczycielDelAll= $1103;
  hcPrzedmiotAdd    = $1110;
  hcPrzedmiotDel    = $1111;
  hcPrzedmiotEdit   = $1112;
  hcPrzedmiotDelAll = $1113;
  hcKlasaAdd        = $1120;
  hcKlasaDel        = $1121;
  hcKlasaEdit       = $1122;
  hcKlasaDelAll     = $1123;
  hcSalaAdd         = $1130;
  hcSalaDel         = $1131;
  hcSalaEdit        = $1132;
  hcSalaDelAll      = $1133;
  hcDzwonekAdd      = $1140;
  hcDzwonekDel      = $1141;
  hcDzwonekEdit     = $1142;
  hcDzwonekDelAll   = $1143;
  hcLekcjaAdd       = $1150;
  hcLekcjaDel       = $1151;
  hcLekcjaEdit      = $1152;
  hcLekcjaDelAll    = $1153;

  hcSlownikiMenu    = $1200;
  hcNauczycieleMenu = $1201;
  hcPrzedmiotyMenu  = $1202;
  hcKlasyMenu       = $1203;
  hcSaleMenu        = $1204;
  hcDzwonkiMenu     = $1205;

  hcPlanLekcjiMenu  = $1206;
  hcSystemMenu      = $1207;
  hcPomocMenu       = $1208;
  hcAboutBox        = $1209;
  hcPlanKlasy       = $1210;
  hcPlanNauczyciela = $1212;
  hcArchiwizacja    = $1213;
  hcOdzysk          = $1214;
  hcQuit            = $1215;
  hcHelp            = $1216;
  hcClickActiveText = $2000;

  { staˆe identyfikuj¥ce kontekst pomocy dla okienek dialogowych }
  hcEditDialogStart        = $2001;
  hcNauczycielDialogNew    = $2011;
  hcNauczycielDialogEdit   = $2012;
  hcPrzedmiotDialogNew     = $2021;
  hcPrzedmiotDialogEdit    = $2022;
  hcKlasaDialogNew         = $2031;
  hcKlasaDialogEdit        = $2032;
  hcSalaDialogNew          = $2041;
  hcSalaDialogEdit         = $2042;
  hcDzwonekDialogNew       = $2051;
  hcDzwonekDialogEdit      = $2052;
  hcLekcjaDialogNew        = $2061;
  hcLekcjaDialogEdit       = $2062;
  hcEditDialogEnd          = $2099;

  hcChooseDialogStart      = $2100;
  hcNauczycielDialogChoose = $2111;
  hcNauczycielDialogEnd    = $2119;
  hcPrzedmiotDialogChoose  = $2121;
  hcPrzedmiotDialogEnd     = $2129;
  hcKlasaDialogChoose      = $2131;
  hcKlasaDialogChooseGrupa = $2132;
  hcKlasaDialogEnd         = $2139;
  hcSalaDialogChoose       = $2141;
  hcSalaDialogEnd          = $2149;
  hcDzwonekDialogChoose    = $2151;
  hcDzwonekDialogEnd       = $2159;
  hcChooseDialogEnd        = $2199;

implementation

begin
end.
