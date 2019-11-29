{$mode objfpc}{$H+}

uses
  Classes,SysUtils,fphttpclient,opensslsockets;

procedure DownloadToFile(const AURL,ASaveTo: String);
var
  LFilePath: String;
  LFS: TFileStream;
begin
  LFilePath := IncludeTrailingPathDelimiter(ASaveTo) + ExtractFileName(AURL);
  if FileExists(LFilePath) then begin
    WriteLn(LFilePath + ' exists, skipping...');
    Exit;
  end;

  LFS := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    WriteLn('Downloading ' + AURL + '...');
    TFPHTTPClient.SimpleGet(AURL, LFS);
  finally
    LFS.Free;
  end;
end;

var
  GPackageLinks,GPackageList: TStringList;
  GPackage,GLink: String;
begin
  if ParamCount <> 2 then begin
    WriteLn('usage: ' + ParamStr(0) + ' <packages links file> <packages to grab file>');
    Exit;
  end;

  GPackageLinks := TStringList.Create;
  GPackageList  := TStringList.Create;
  try
    GPackageLinks.LoadFromFile(ParamStr(1));
    GPackageList.LoadFromFile(ParamStr(2));
    for GPackage in GPackageList do begin
      GLink := GPackageLinks.Values[GPackage];
      if GLink <> '' then
        DownloadToFile(GLink,GetCurrentDir)
      else
        WriteLn(StdErr,'No link found for package ' + GPackage);
    end;
  finally
    GPackageList.Free;
    GPackageLinks.Free;
  end;
end.
