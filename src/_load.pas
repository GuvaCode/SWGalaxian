unit _load;

interface

uses
  _var, raylib, Classes, SysUtils;

procedure LoadData; // Loading game resources
procedure UnloadAllResources;

implementation

//----------------------------------------------------------------------------------------------------------------------------------------------------

procedure generate_text(FontSize: Integer);  // Рисует justify текст на текстуру
var
  image: TImage;
  a, b, c, spc_count, spc_w: integer;
  s: string;
  tsl1: TStringList;
  textWidth: integer;
  interval: integer;
begin
  // Создаем изображение
  image := GenImageColor(256, 1024, ColorCreate(255,255,255,0) );
  interval :=  FontSize *2;
  tsl1 := TStringList.Create;
  tsl.Clear;

  // Загружаем данные текста
  //getdata('text', ms);
  tsl.LoadFromFile('data/text');

  for a := 0 to tsl.Count - 1 do
  begin
    s := tsl[a];
    tsl1.Clear;
    spc_count := 0;
    spc_w := 0;
    c := 0;

    if Length(s) > 0 then
    begin
      if s[1] <> '*' then
      begin
        // Разбиваем строку на слова и пробелы
        tsl1.Add('');
        for b := 1 to length(s) do
        begin
          if s[b] = ' ' then
          begin
            tsl1.Add('');
            tsl1[tsl1.Count - 1] := tsl1[tsl1.Count - 1] + ' ';
            inc(spc_count);
            tsl1.Add('');
          end
          else
            tsl1[tsl1.Count - 1] := tsl1[tsl1.Count - 1] + s[b];
        end;

        // Подсчитываем общую ширину текста
        c := 0;
        for b := 0 to tsl1.Count - 1 do
          if (tsl1[b] <> ' ') and (tsl1[b] <> '') then
            inc(c, MeasureText(PChar(tsl1[b]), FontSize));

        // Вычисляем ширину пробелов для выравнивания по ширине
        if spc_count > 0 then
          spc_w := (254 - c) div spc_count;

        // Рисуем текст на изображении
        c := 1;
        for b := 0 to tsl1.Count - 1 do
        begin
          s := tsl1[b];
          if s <> '' then
          begin
            if s = ' ' then
              c := c + spc_w
            else
            begin
               ImageDrawText(@image, PChar(s), c, a * interval, FontSize, WHITE);
              // ImageDrawTextEx(@image, GetFontDefault, PChar(s), Vector2Create(c, a * 22), FontSize ,1, WHITE);
              inc(c, MeasureText(PChar(s), FontSize));
            end;
          end;
        end;
      end
      else
      begin
        // Строка с '*' в начале - центрированный текст
        s := copy(s, 2, length(s) - 1);
        textWidth := MeasureText(PChar(s), FontSize);
        ImageDrawText(@image, PChar(s), (256 - textWidth) div 2, a * interval, FontSize, WHITE);
        //ImageDrawTextEx(@image, GetFontDefault, PChar(s), Vector2Create((256 - textWidth) div 2, a * 22), FontSize, 1, WHITE);
      end;
    end;
  end;

  tsl1.Free;

  // Экспортируем изображение в текстуру
  swtext := LoadTextureFromImage(image);

  //ExportImage(image,'t.png');
  // Освобождаем изображение
  UnloadImage(image);


end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
function loadTex(Name: string): TTexture;
begin
  Result := LoadTexture(PAnsiChar('data/' + Name));
  //SetTextureFilter(Result, TEXTURE_FILTER_ANISOTROPIC_8X);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
function loadSnd(Name: string): TSound;
begin
  FillChar(Result, SizeOf(Result), 0);

  if IsAudioDeviceReady() then
    Result := LoadSound(PAnsiChar('data/' + Name));
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure LoadData;
var
  a: integer;

begin
  for a := 0 to high(starsky[0]) do
  begin
    starsky[0, a] := random(800);              // x
    starsky[1, a] := random(600);              // y
    starsky[2, a] := (random(200) + 50) / 255; // brightness
  end;

  new_level := true;
  //fnt := loadFont('data/Stjldbl1.ttf');
  generate_text(10);

  s[s_bomb] := loadSnd('bomb.wav');
  s[s_zap] := loadSnd('zap.wav');
  s[s_expl] := loadSnd('expl1.wav');
  s[s_blip] := loadSnd('blip.wav');
  s[s_damage] := loadSnd('damage.wav');
  s[s_shot1] := loadSnd('xwingshot1.wav');
  s[s_shot2] := loadSnd('xwingshot2.wav');
  s[s_tie_shot2] := loadSnd('tieshot2.wav');
  s[s_tiefly0] := loadSnd('tiefly0.wav');
  s[s_tiefly1] := loadSnd('tiefly1.wav');
  s[s_r2d2] := loadSnd('r2d2-1.wav');

  swlogo := loadTex('swlogo.png');
  xwing := loadTex('xwing.png');
  exh1 := loadTex('exhaust1.png');
  shot1 := loadTex('shot1.png');
  lives := loadTex('lives.png');
  rpm := loadTex('rpm.png');
  multishot := loadTex('multishot.png');
  bomb := loadTex('bomb1.png');
  enter := loadTex('enter.png');
  esc := loadTex('esc.png');

  tief := loadTex('tief_strip.png');
  tiei := loadTex('tiei_strip.png');
  tieb := loadTex('tieb_strip.png');

  spark := loadTex('spark_strip.png');
                   // bomexpl_strip.png
  blast := loadTex('bomexpl_strip.png');///('blast_strip.png');
  expl := loadTex('expl_strip.png');


  MenuMusic :=LoadMusicStream('data/crazy.mod');
  MenuMusic.looping := true;

  IntroMusic :=LoadMusicStream('data/intro.compat.xm');
  IntroMusic.looping := true;

  //fnt1 := LoadFont('data/Starjhol.ttf');
  fnt1 := LoadFontEx(PChar('data/SFDistantGalaxy.ttf'), 48, nil, 0);
  fnt2 := LoadFontEx(PChar('data/SFDistantGalaxy.ttf'), 24, nil, 0);
 // GenTextureMipmaps(@Font.Texture);

  camera := Default(TCamera3D);
  camera :=Camera3DCreate(
      Vector3Create(0, 0, 500),
      Vector3Create(0, 0, 0),
      Vector3Create(0, 1, 0),
      45,
      0
    );



end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure UnloadAllResources;
var
  i: integer;
begin
  // Выгрузка текстур
  if IsTextureValid(swtext) then UnloadTexture(swtext);
  if IsTextureValid(swlogo) then UnloadTexture(swlogo);
  if IsTextureValid(xwing) then UnloadTexture(xwing);
  if IsTextureValid(exh1) then UnloadTexture(exh1);
  if IsTextureValid(shot1) then UnloadTexture(shot1);
  if IsTextureValid(lives) then UnloadTexture(lives);
  if IsTextureValid(rpm) then UnloadTexture(rpm);
  if IsTextureValid(multishot) then UnloadTexture(multishot);
  if IsTextureValid(bomb) then UnloadTexture(bomb);
  if IsTextureValid(enter) then UnloadTexture(enter);
  if IsTextureValid(esc) then UnloadTexture(esc);
  if IsTextureValid(tief) then UnloadTexture(tief);
  if IsTextureValid(tiei) then UnloadTexture(tiei);
  if IsTextureValid(tieb) then UnloadTexture(tieb);
  if IsTextureValid(spark) then UnloadTexture(spark);
  if IsTextureValid(blast) then UnloadTexture(blast);
  if IsTextureValid(expl) then UnloadTexture(expl);

  // Выгрузка звуков
  for i := 0 to Max_Sounds do
  begin
    if IsSoundValid(s[i]) then
      UnloadSound(s[i]);
  end;

  // Выгрузка музыки
  if IsMusicValid(MenuMusic) then
    UnloadMusicStream(MenuMusic);

  if IsMusicValid(IntroMusic) then
    UnloadMusicStream(IntroMusic);

  // Выгрузка шрифтов
  if IsFontValid(fnt1) then
    UnloadFont(fnt1);

  if IsFontValid(fnt2) then
    UnloadFont(fnt2);

  // Очистка динамических массивов
  SetLength(a_shots_ally, 0);
  SetLength(a_shots_enemy, 0);
  SetLength(a_explosions, 0);
  SetLength(a_enemy, 0);
  SetLength(a_rally, 0);
  SetLength(a_score, 0);
  SetLength(a_DelayAction, 0);
  SetLength(a_bonus, 0);

  // Закрытие файла если открыт
  // Если файловая переменная используется, можно добавить:
  // CloseFile(F); // если файл открыт

  // Сброс состояния музыки

  MusicInitialized := False;
  StopMusicStream(MenuMusic);
  StopMusicStream(IntroMusic);


end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
end.
