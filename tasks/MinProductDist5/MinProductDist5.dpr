program MinProductDist5;
{$APPTYPE CONSOLE}

uses
  Windows;

{ Наименьшее произведение двух элементов последовательности,
  различающихся порядковыми номерами не менее чем на 5.
  Последовательность в массиве не хранится — только буфер из 5 чисел. }

procedure OutS(const S: string);
var
  W: WideString;
  Written: DWORD;
  H: THandle;
begin
  if S = '' then Exit;
  H := GetStdHandle(STD_OUTPUT_HANDLE);
  if GetFileType(H) = FILE_TYPE_CHAR then
  begin
    W := WideString(S);
    WriteConsoleW(H, PWideChar(W), Length(W), Written, nil);
  end
  else
    Write(S);
end;

procedure OutLn(const S: string);
var
  Written: DWORD;
  H: THandle;
  CrLf: WideString;
begin
  OutS(S);
  H := GetStdHandle(STD_OUTPUT_HANDLE);
  if GetFileType(H) = FILE_TYPE_CHAR then
  begin
    CrLf := #13#10;
    WriteConsoleW(H, PWideChar(CrLf), 2, Written, nil);
  end
  else
    WriteLn;
end;

var
  N, I, X, Y, PrefMin, Ans, P: Integer;
  Buf: array[0..4] of Integer;
  Head, Count: Integer;
  HasPref: Boolean;

begin
  OutLn('Минимальное произведение двух чисел с разницей позиций >= 5');
  OutLn('');
  OutLn('Ввод:');
  OutLn('  1) сначала N — длина последовательности (от 6 до 10000)');
  OutLn('  2) затем N целых неотрицательных чисел (каждое <= 1000)');
  OutLn('     можно в одной строке или с новой строки');
  OutLn('');
  OutLn('Пример:');
  OutLn('  8');
  OutLn('  1 2 3 4 5 6 7 8');
  OutLn('Ответ для примера: 6  (например 1*6)');
  OutLn('');

  OutS('N = ');
  Read(N);
  if (N < 6) or (N > 10000) then
  begin
    OutLn('Ошибка: N должно быть от 6 до 10000.');
    OutLn('Нажмите Enter для выхода...');
    ReadLn;
    if not Eof then ReadLn;
    Halt(1);
  end;

  OutS('Введите ');
  Write(N);
  OutLn(' чисел:');

  HasPref := False;
  PrefMin := 0;
  Ans := MaxInt;
  Head := 0;
  Count := 0;

  for I := 1 to N do
  begin
    Read(X);

    if Count = 5 then
    begin
      Y := Buf[Head];
      Head := (Head + 1) mod 5;
      Dec(Count);
      if (not HasPref) or (Y < PrefMin) then
      begin
        PrefMin := Y;
        HasPref := True;
      end;
    end;

    if HasPref then
    begin
      P := X * PrefMin;
      if P < Ans then
        Ans := P;
    end;

    Buf[(Head + Count) mod 5] := X;
    Inc(Count);
  end;

  OutLn('');
  OutS('Результат: ');
  WriteLn(Ans);
  OutLn('');
  OutLn('Нажмите Enter для выхода...');
  ReadLn;
  if not Eof then
    ReadLn;
end.
