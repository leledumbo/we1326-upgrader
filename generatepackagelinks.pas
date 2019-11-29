{$mode objfpc}{$H+}

uses
  Classes,SysUtils,fphttpclient,opensslsockets,httpprotocol;

const
  URLTemplateMT7621     = 'https://downloads.openwrt.org/releases/%s/targets/ramips/mt7621/';
  URLTemplateMIPSEL24KC = 'https://downloads.openwrt.org/releases/%s/packages/mipsel_24kc/';

function BuildPackageLinks(const AVersion: String): TStringList;

  function ParsePackageAndFileName(const APackageFileContent,APrefix: String): TStringList;
  var
    LTempSL: TStringList;
    LLine,LKey,LValue,LPackage: String;
    LColonPos: Word;
  begin
    LTempSL := TStringList.Create;
    LTempSL.Text := APackageFileContent;

    Result := TStringList.Create;
    with LTempSL do
      try
        for LLine in LTempSL do begin
          LColonPos := Pos(':',LLine);
          if LColonPos > 0 then begin
            LKey   := Copy(LLine,1,LColonPos - 1);
            LValue := Copy(LLine,LColonPos + 2,Length(LLine) - LColonPos + 1);
            case LKey of
              'Package' : LPackage := LValue;
              'Filename': Result.Values[LPackage] := IncludeHTTPPathDelimiter(APrefix) + LValue;
            end;
          end;
        end;
      finally
        Free;
      end;
  end;

var
  LURLMT7621,LURLMIPSEL24KC,LURL: String;
  LURLsToPackages: array of String;
  LTempSL: TStringList;
begin
  LURLMT7621     := Format(URLTemplateMT7621,[AVersion]);
  LURLMIPSEL24KC := Format(URLTemplateMIPSEL24KC,[AVersion]);

  LURLsToPackages := [
    LURLMT7621 + 'packages',
    LURLMIPSEL24KC + 'base',
    LURLMIPSEL24KC + 'luci',
    LURLMIPSEL24KC + 'packages'
  ];

  Result := TStringList.Create;
  for LURL in LURLsToPackages do begin
    WriteLn('Downloading ' + LURL + '/Packages...');
    LTempSL := ParsePackageAndFileName(TFPHTTPClient.SimpleGet(LURL + '/Packages'),LURL);
    with LTempSL do
      try
        Result.AddStrings(LTempSL);
      finally
        Free;
      end;
  end;
end;

var
  GPackageLinks: TStringList;
begin
  if ParamCount <> 1 then begin
    WriteLn('usage: ' + ParamStr(0) + ' <package version to grab>');
    Exit;
  end;

  GPackageLinks := BuildPackageLinks(ParamStr(1));
  WriteLn(GPackageLinks.Text);
  GPackageLinks.Free;
end.