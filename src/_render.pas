unit _render;

interface

uses
  _var, _draw, raylib, SysUtils;

procedure render_menu;
procedure render_intro_ALTA;
procedure render_intro_logo;
procedure render_intro_text;
procedure render_intro_scroll;
procedure render_game;

implementation

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_stars;
var
  a: integer;
begin
  for a := 0 to high(starsky[0]) do
  begin
    DrawPixelV(
      Vector2Create(starsky[0, a], starsky[1, a]),
      ColorCreate(
        trunc(starsky[2, a] * 255),
        trunc(starsky[2, a] * 255),
        trunc(starsky[2, a] * 255),
        255
      )
    );
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_menu;
var
  s: string;  ms: TVector2;
  textWidth: integer;
begin
  render_stars;

  // draw art



  // Рисуем логотип с эффектом свечения
  DrawTexturePro(
    swlogo,
    RectangleCreate(0, 0, swlogo.width, swlogo.height),
    RectangleCreate(400 - 128, 150 - 64, 256, 128),
    Vector2Create(0, 0),
    0,
    ColorCreate(236, 199, 96, 255)
  );

  s := 'HIGH SCORE';
  ms := MeasureTextEx(Fnt2, PAnsiChar(s), 24,1);//   MeasureText(PChar(s), 12);
  DrawTextEx(fnt2, PAnsiChar(s), Vector2Create(400 - (ms.x/2), 250 - 24/2) , 24, 1,  ColorCreate(236, 199, 96, 255));

  s := IntToStr(player.hiscore);
  ms := MeasureTextEx(Fnt2, PAnsiChar(s), 24,1);
  DrawTextEx(fnt2, PAnsiChar(s), Vector2Create(400 - (ms.x/2), 280 - 24/2) , 24, 1,  ColorCreate(236, 199, 96, 255));

  s := 'Start game';
  ms := MeasureTextEx(Fnt2, PAnsiChar(s), 24,1);
  DrawTextEx(fnt2, PAnsiChar(s), Vector2Create(400 - (ms.x/2), 350 - 24/2) , 24, 1,  ColorCreate(236, 199, 96, 255));
 // DrawText('Start game', 370, 350, 12, ColorCreate(236, 199, 96, 255));


  // DrawText(PChar(s), 400 - textWidth div 2, 270, 16, ColorCreate(236, 199, 96, 255));

  // Кнопка "Start game"
  DrawTexturePro(
    enter,
    RectangleCreate(0, 0, enter.width, enter.height),
    RectangleCreate(400 + (ms.x/2) + 10, 350 - 34/2 , 32, 32),
    Vector2Create(0, 0),
    0,
    ColorCreate(236, 199, 96, 255)
  );


  s := 'Exit game';
  ms := MeasureTextEx(Fnt2, PAnsiChar(s), 24,1);
  DrawTextEx(fnt2, PAnsiChar(s), Vector2Create(400 - (ms.x/2), 400 - 24/2) , 24, 1,  ColorCreate(236, 199, 96, 255));




  // Кнопка "Exit game"
  DrawTexturePro(
    esc,
    RectangleCreate(0, 0, esc.width, esc.height),

    RectangleCreate(400 + (ms.x/2) + 10, 400 - 34/2 , 32, 32),
    Vector2Create(0, 0),
    0,
    ColorCreate(236, 199, 96, 255)
  );


   s := '(C) Alexandr "Shirson" Nevskiy 2008 / Vadim "GuvaCode" Gunko 2026';
   textWidth := MeasureText(PChar(s), 8);
   DrawText(PChar(s), 400 - textWidth div 2, 580, 8, ColorCreate(236, 199, 96, 255));

  {
   DrawTexturePro(
     art,
     RectangleCreate(0, 0, art.width, art.height),
     RectangleCreate(0, 600 - art.height, art.width, art.height),
     Vector2Create(0, 0),
     0,
     ColorCreate(236, 199, 96, 255)
   );


  DrawTexturePro(
    art,
    RectangleCreate(0, 0, art.width, art.height),
    RectangleCreate(800 -  art.width, 600 - art.height, art.width, art.height),
    Vector2Create(0, 0),
    0,
    ColorCreate(236, 199, 96, 255)
  );
 }

end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_intro_ALTA;
var
  color: TColor;
begin
  color := ColorCreate(
    trunc(51 * introfade / 255),
    trunc(204 * introfade / 255),
    trunc(255 * introfade / 255),
    255
  );

  DrawText('A long time ago, in a galaxy far,', 200, 220, 20, color);
  DrawText('far away....', 200, 260, 20, color);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_intro_logo;
begin
  render_stars;

  DrawTexturePro(
    swlogo,
    RectangleCreate(0, 0, swlogo.width, swlogo.height),
    RectangleCreate(
      400 - trunc(introfade / 2),
      300 - trunc(introfade / 4),
      trunc(introfade),
      trunc(introfade / 2)
    ),
    Vector2Create(0, 0),
    0,
    ColorCreate(236, 199, 96, 255)
  );
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_intro_text;
var
  color: TColor;
begin
  render_stars;

  // Настройка 3D камеры ( FOV 45, Near 0.1, Far 4096 )
  // Камера в (0,0,500) математически эквивалентна сдвигу мира на (0,0,-500)
  BeginMode3D(Camera);
         // camera.position := Vector3Create(-10.0, 15.0, -10.0);


  // Формируем цвет с учетом глобального множителя затухания (dbl)
  color := ColorCreate(trunc(dbl * 236), trunc(dbl * 199), trunc(dbl * 96), 255);

  // Передаем introfade в качестве Z (глубины), как было в оригинале
  drawtxt(swtext, 0, 0, introfade, swtext.width, swtext.height, 0, color);

  EndMode3D();
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_intro_scroll;
var s: String; ms: TVector2;
begin
  render_stars;
  s:= 'GET READY';
  ms := MeasureTextEx( fnt1, PAnsiChar(s), 48, 1);
  if trunc(introfade) > 200 then
  begin
    DrawTextEx(fnt1, PChar(s), Vector2Create(400 - (ms.x/2), 300 - 48/2) , 48, 1,  ColorCreate(236, 199, 96, 255));
  end;

end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure DrawTextureFromStrip(
  texture: TTexture;
  frame, totalFrames: integer;
  destRect: TRectangle;
  origin: TVector2;
  rotation: single;
  color: TColor
);
var
  frameWidth, frameHeight: integer;
  sourceRect: TRectangle;
begin
  frameWidth := texture.width div totalFrames;
  frameHeight := texture.height;

  sourceRect.x := frame * frameWidth;
  sourceRect.y := 0;
  sourceRect.width := frameWidth;
  sourceRect.height := frameHeight;

  DrawTexturePro(texture, sourceRect, destRect, origin, rotation, color);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure render_game;
var
  a, b: integer;
  s: string;
  textWidth: integer;
  frameIndex: integer;
  flameWidth: integer;
  ms: TVector2;
begin
  // Отрисовка очков
  if high(a_score) >= 0 then
    for a := 0 to high(a_score) do
    begin
      DrawText(
        PChar(a_score[a].value + ' '),
        trunc(a_score[a].x),
        trunc(a_score[a].y),
        8,
        ColorCreate(
          trunc(141 / 255 * a_score[a].frame),
          trunc(207 / 255 * a_score[a].frame),
          trunc(244 / 255 * a_score[a].frame),
          255
        )
      );
    end;

  render_stars;

  // Игрок
  DrawTexturePro(
    xwing,
    RectangleCreate(0, 0, xwing.width, xwing.height),
    RectangleCreate(trunc(player.x - 24), trunc(player.y - 24), 48, 48),
    Vector2Create(0, 0),
    0,
    WHITE
  );

  // Враги
  if high(a_enemy) >= 0 then
  begin
    for a := 0 to high(a_enemy) do
    begin
      b := trunc(a_enemy[a].frame);

      if b < 0 then
        b := 18 + b;

      // Выбираем текстуру в зависимости от типа врага
      case a_enemy[a].bif of
        0: // Fighter
        begin
          if a_enemy[a].order = 200 then
            DrawTextureFromStrip(
              tief,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(196, 196, 196, 255)
            )
          else
            DrawTextureFromStrip(
              tief,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(255, 255, 255, 255)
            );
        end;

        1: // Interceptor
        begin
          if a_enemy[a].order = 200 then
            DrawTextureFromStrip(
              tiei,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(196, 196, 196, 255)
            )
          else
            DrawTextureFromStrip(
              tiei,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(255, 255, 255, 255)
            );
        end;

        2: // Bomber
        begin
          if a_enemy[a].order = 200 then
            DrawTextureFromStrip(
              tieb,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(196, 196, 196, 255)
            )
          else
            DrawTextureFromStrip(
              tieb,
              b,
              18,
              RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
              Vector2Create(16, 16),
              a_enemy[a].angle,
              ColorCreate(255, 255, 255, 255)
            );
        end;
      end;

      // Искры для врагов в состоянии 200
      if (a_enemy[a].order = 200) and (random(10) = 0) then
      begin
        frameIndex := random(8);

        DrawTextureFromStrip(
          spark,
          frameIndex,
          8,
          RectangleCreate(trunc(a_enemy[a].x - 16), trunc(a_enemy[a].y - 16), 32, 32),
          Vector2Create(0, 0),
          a_enemy[a].angle,
          ColorCreate(41, 207, 255, 255)
        );
      end;
    end;

    // Отображение номера этапа
    s := ' STAGE ' + IntToStr(player.Stage + 1) + ' ';


    if a_enemy[0].delay > 0 then
    begin
     ms := MeasureTextEx( fnt2, PAnsiChar(s), 24, 1);
     DrawTextEx(fnt1, PChar(s), Vector2Create(400 - (ms.x/2), 150 - 24/2) , 24, 1,  ColorCreate(236, 199, 96, 255));
     // DrawText(PChar(s), 400 - textWidth div 2, 150, 16, ColorCreate(255, 255, 255, 255));
    end;
  end;


  // Эффект выхлопа - вычисляем ширину один раз
  flameWidth := 21 + random(4);
  BeginBlendMode(BLEND_ADDITIVE);

  DrawTexturePro(
      exh1,
      RectangleCreate(0, 0, exh1.width, exh1.height),
      RectangleCreate(
        Round(player.x - flameWidth / 2),  // левый край по центру игрока
        Round(player.y + 18),               // верхний край
        flameWidth,                         // та же ширина
        22
      ),
      Vector2Create(0, 0),
      0,
      ColorCreate(237, 126, 137, 255)
    );
   EndBlendMode();
  // Выстрелы игрока
  if high(a_shots_ally) >= 0 then
    for a := 0 to high(a_shots_ally) do
    begin
      DrawTexturePro(
        shot1,
        RectangleCreate(0, 0, shot1.width, shot1.height),
        RectangleCreate(trunc(a_shots_ally[a].x - 2), trunc(a_shots_ally[a].y - 16), 4, 32),
        Vector2Create(2, 16),
        a_shots_ally[a].angle,
        ColorCreate(255, 120, 130, 255)
      );
    end;

  // Бонусы
  if high(a_bonus) >= 0 then
    for a := 0 to high(a_bonus) do
    begin
      case a_bonus[a].value[1] of
        '0':
        begin
          DrawTexturePro(
            lives,
            RectangleCreate(0, 0, lives.width, lives.height),
            RectangleCreate(trunc(a_bonus[a].x - 16), trunc(a_bonus[a].y - 16), 32, 32),
            Vector2Create(0, 0),
            0,
            ColorCreate(255, 255, 255, 255)
          );

          s := '+1 Life ';
          DrawText(
            PChar(s),
            trunc(a_bonus[a].x - MeasureText(PChar(s), 8) div 2),
            trunc(a_bonus[a].y - 36),
            8,
            ColorCreate(0, 196, 0, 255)
          );
        end;

        '1':
        begin
          DrawTexturePro(
            rpm,
            RectangleCreate(0, 0, rpm.width, rpm.height),
            RectangleCreate(trunc(a_bonus[a].x - 16), trunc(a_bonus[a].y - 16), 32, 32),
            Vector2Create(0, 0),
            0,
            ColorCreate(255, 255, 255, 255)
          );

          s := 'Rapid fire';
          DrawText(
            PChar(s),
            trunc(a_bonus[a].x - MeasureText(PChar(s), 8) div 2),
            trunc(a_bonus[a].y - 36),
            8,
            ColorCreate(220, 0, 0, 255)
          );
        end;

        '2':
        begin
          DrawTexturePro(
            multishot,
            RectangleCreate(0, 0, multishot.width, multishot.height),
            RectangleCreate(trunc(a_bonus[a].x - 16), trunc(a_bonus[a].y - 16), 32, 32),
            Vector2Create(0, 0),
            0,
            ColorCreate(255, 255, 255, 255)
          );

          s := 'Multishot';
          DrawText(
            PChar(s),
            trunc(a_bonus[a].x - MeasureText(PChar(s), 8) div 2),
            trunc(a_bonus[a].y - 36),
            8,
            ColorCreate(0, 0, 255, 255)
          );
        end;
      end;
    end;

  // Выстрелы врагов
  if high(a_shots_enemy) >= 0 then
    for a := 0 to high(a_shots_enemy) do
    begin
      if a_shots_enemy[a].tp = 0 then
      begin
        DrawTexturePro(
          shot1,
          RectangleCreate(0, 0, shot1.width, shot1.height),
          RectangleCreate(trunc(a_shots_enemy[a].x - 2), trunc(a_shots_enemy[a].y - 16), 4, 32),
          Vector2Create(2, 16),
          a_shots_enemy[a].angle,
          ColorCreate(120, 255, 137, 255)
        );
      end;

      if a_shots_enemy[a].tp = 1 then
      begin
        // Пульсация размера
        if a_shots_enemy[a].count mod 20 in [1..2] then
          b := 24
        else
          b := 8;

        DrawTexturePro(
          bomb,
          RectangleCreate(0, 0, bomb.width, bomb.height),
          // Используем Round для более точного позиционирования без "дрожания"
          RectangleCreate(
            Round(a_shots_enemy[a].x - b / 2),
            Round(a_shots_enemy[a].y - b / 2),
            b,
            b
          ),
          // ГЛАВНОЕ ИСПРАВЛЕНИЕ: Вращаем вокруг ЦЕНТЕРА ИСХОДНОЙ ТЕКСТУРЫ, а не b/2
          Vector2Create(bomb.width / 2, bomb.height / 2),
          0,
          ColorCreate(140, 200, 255, 255)
        );
      end;
    end;

  // Взрывы - используем strip текстуры
  if high(a_explosions) >= 0 then
    for a := 0 to high(a_explosions) do
    begin
      BeginBlendMode(BLEND_ADDITIVE);
      // Для взрывов используем expl или blast в зависимости от типа
      if a_explosions[a].tp = 0 then // blast
       { DrawTextureFromStrip(
          blast,
          a_explosions[a].frame,
          {36}24,
          RectangleCreate(
            trunc(a_explosions[a].x - a_explosions[a].size / 2),
            trunc(a_explosions[a].y - 4 - a_explosions[a].size / 2),
            trunc(a_explosions[a].size),
            trunc(a_explosions[a].size)
          ),
          Vector2Create(a_explosions[a].size / 2, a_explosions[a].size / 2),
          a_explosions[a].angle,
          WHITE
        ) }
      DrawTextureFromStrip(
        blast,
        a_explosions[a].frame,
        64,
        RectangleCreate(
          trunc(a_explosions[a].x ),//- a_explosions[a].size / 2),
          trunc(a_explosions[a].y ),// - a_explosions[a].size / 2),
          trunc(a_explosions[a].size),
          trunc(a_explosions[a].size)
        ),
        Vector2Create(a_explosions[a].size / 2, a_explosions[a].size / 2),
        0,
        ColorCreate(255, 255, 255, 255)
      )
      else // expl
        DrawTextureFromStrip(
          expl,
          a_explosions[a].frame,
          36,
          RectangleCreate(
            trunc(a_explosions[a].x - a_explosions[a].size / 2),
            trunc(a_explosions[a].y - 4 - a_explosions[a].size / 2),
            trunc(a_explosions[a].size),
            trunc(a_explosions[a].size)
          ),
          Vector2Create(a_explosions[a].size / 2, a_explosions[a].size / 2),
          a_explosions[a].angle,
          ColorCreate(255, 255, 255, 255)
        );
      EndBlendMode();
    end;

  // HUD - Очки
  s := IntToStr(Player.counting);
  DrawText(PChar(s), 700 - MeasureText(PChar(s), 10), 8, 10, ColorCreate(255, 255, 255, 255));
  DrawText('Score', 710, 8, 10, ColorCreate(255, 255, 255, 255));

  // HUD - Этап
  s := IntToStr(player.Stage + 1);
  DrawText(PChar(s), 500 - MeasureText(PChar(s), 10), 8, 10, ColorCreate(255, 255, 255, 255));
  DrawText('Stage', 510, 8, 10, ColorCreate(255, 255, 255, 255));

  // HUD - Жизни
  s := IntToStr(Player.Lives);
  DrawText(PChar(s), 300 - MeasureText(PChar(s), 10), 8, 10, ColorCreate(255, 255, 255, 255));
  DrawText('Lives', 310, 8, 10, ColorCreate(255, 255, 255, 255));

  // HUD - Скорость стрельбы
  case Player.RPM of
    50: s := 'x1';
    40: s := 'x2';
    30: s := 'x3';
    20: s := 'Max';
  end;

  DrawText(PChar(s), 100 - MeasureText(PChar(s), 10), 8, 10, ColorCreate(255, 255, 255, 255));
  DrawText('Firing rate', 110, 8, 10, ColorCreate(255, 255, 255, 255));

  // PAUSE
  if pause then
  begin
    s := 'PAUSE';
    DrawText(PChar(s), 400 - MeasureText(PChar(s), 16) div 2, 250, 16, ColorCreate(255, 255, 255, 255));
  end;

  // GAME OVER
  if player.Lives = 0 then
  begin
    s := 'GAME OVER';
     ms := MeasureTextEx( fnt1, PAnsiChar(s), 48, 1);
    DrawTextEx(fnt1, PAnsiChar(s), Vector2Create(400 - (ms.x/2), 300 - 48/2) , 48, 1,  ColorCreate(236, 199, 96, 255));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
end.
